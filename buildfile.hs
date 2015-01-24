#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}

import           Control.Monad (when)
import           Data.Attoparsec.Text (Parser)
import qualified Data.Attoparsec.Text as P
import           Data.Char as C (isSpace)
import           Data.Either (isRight)
import qualified Data.List as L
import qualified Data.List.Split as L (splitWhen)
import           Data.Maybe (fromJust)
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import           Development.Shake
import           Development.Shake.FilePath
import           Prelude hiding (lines)


main :: IO ()
main = shakeArgs shakeOptions $ do

  -- Generating the files for the Unrestricted calculus
  want (map fst filesForUnrestricted)

  "src/Logic/Unrestricted//*.agda" *> \target -> do
    let src = fromJust (lookup target filesForUnrestricted)
    liftIO $
      T.writeFile target
        .   restrictSource replacementListForUnrestricted blacklistForUnrestricted
        =<< T.readFile src

  -- Generating the files for the Linear calculus
  want (map fst filesForLinear)

  "src/Logic/Linear//*.agda" *> \target -> do
    let src = fromJust (lookup target filesForLinear)
    need [src]
    liftIO $
      T.writeFile target
        .   restrictSource replacementListForLinear blacklistForLinear
        =<< T.readFile src

  -- Generating the files for the Lambek calculus
  want (map fst filesForLambek)

  "src/Logic/Lambek//*.agda" *> \target -> do
    let src = fromJust (lookup target filesForLambek)
    need [src]
    liftIO $
      T.writeFile target
        .   restrictSource replacementListForLambek blacklistForLambek
        =<< T.readFile src

  -- Generating the HTML listings
  phony "listings" $ do
    (Just agdaHome) <- getEnv "AGDA_HOME"
    need ["src/Everything.agda"]
    cmd ("agda" :: String)
        ["--include-path=src"
        ,"--include-path=" ++ agdaHome
        ,"--html"
        ,"src/Everything.agda"
        ,"-v0"]

  want ["src/Everything.agda"]

  "src/Everything.agda" *> \_ -> do
    need (map snd filesForLambek)
    liftIO $ removeFiles "src" ["Everything.agda"]
    cmd ("./GenerateEverything.hs" :: String)

  -- Cleaning up after all code generators
  phony "clobber" $ do
    putNormal "Removing Everything.agda"
    liftIO $ removeFiles "src" ["Everything.agda"]
    putNormal "Removing generated files for Lambek calculus"
    liftIO $ removeFiles "." (map fst filesForLambek)
    putNormal "Removing generated files for Linear calculus"
    liftIO $ removeFiles "." (map fst filesForLinear)
    putNormal "Removing generated files for Unrestricted calculus"
    liftIO $ removeFiles "." (map fst filesForUnrestricted)




--------------------------------------------------------------------------------
-- Utility function which restricts an Agda source file to somewhat
-- intelligently remove lines which refer to blacklisted symbols.
-------------------------------------------------------------------------------

-- |Parse a file and remove all groups which contain illegal symbols.
restrictSource :: [(Text, Text)] -> [Text] -> Text -> Text
restrictSource replacements blacklist input = let

  -- The algorithm to remove illegal lines is as follows:
  -- First we divide the text up by lines, and group the lines that
  -- are separated by one or more blank lines.
  lines   = T.lines input
  groups  = L.splitWhen isBlank lines
  groups' = map (filter (not . isBlank)) groups

  -- Then we scan over all the groups, and remove those which have a
  -- type signature which mentions one of the blacklisted characters.
  -- The idea here is to remove functions that implement an illegal
  -- type signature.
  noIllegalTS = filter (all (not . isIllegalTS)) groups'

  -- The remaining groups are concatenated back together, now
  -- separated by a single blank line (the reason it has 80 spaces in
  -- there will become apparent soon).
  concatted = L.intercalate [T.append (T.replicate 80 " ") "\n"] noIllegalTS

  -- We then traverse the lines a single time and mark any line
  -- mentioning a blacklisted character.
  --
  -- After that, we traverse the lines a second time. This time with
  -- an accumulating parameter which keeps track of the status of the
  -- previous line. If the previous line was marked as illegal, but
  -- the current line isn't, we check if:
  --   a. the current line is a with statement, in which case it'd be
  --      the continuation of the previous line, or;
  --   b. the current line is more deeply indented than the previous
  --      line, in which case it'd be the direct continuation or in a
  --      where-clause. This case explains the 80 spaces mentioned above.
  --
  -- We then remove all marked lines.
  markIllegal  = zip (map isLegal concatted) concatted
  markIllegal' :: [(Bool, Text)]
  markIllegal' = snd (L.mapAccumL go (True , 0) markIllegal)
    where go :: (Bool , Int) -> (Bool , Text) -> ((Bool , Int) , (Bool , Text))
          go (_     , iX) (False , lnY) = ((False , min iX (indent lnY)) , (False , lnY))
          go (True  , _ ) (True  , lnY) = ((True  ,         indent lnY ) , (True  , lnY))
          go (False , iX) (True  , lnY) = ((legal , iX) , (legal , lnY))
            where
              legal         = notDeeper && notWithClause
              notDeeper     = iX >= indent lnY
              notWithClause = "..." /= T.take 3 (T.stripStart lnY)
  stripMarked  = map snd (filter fst markIllegal')
  stripEnd     = map T.stripEnd stripMarked

  -- We then perform a number of in-place substitutions, which
  -- replace references to the Lambek Grishin calculus with
  -- references to the Lambek calculus.
  replaced = replaceAll (T.unlines stripEnd)

  in replaced

  where

  -- |Check if text contains any blacklisted items.
  isLegal :: Text -> Bool
  isLegal  = not . foldr (\x f y -> f y || x `T.isInfixOf` y) (const False) blacklist

  -- |Check if text is a type signature containing blacklisted items.
  isIllegalTS :: Text -> Bool
  isIllegalTS = isRight . P.parseOnly p
    where
      p :: Parser ()
      p = do
        _ <- P.takeWhile (not . isSpace)
        _ <- P.many1 P.space
        _ <- P.char ':'
        rest <- P.takeText

        when (isLegal rest) $
          fail "Type signature contains no blacklisted items."


  -- |Perform all replacements given in the `replacements` paramter.
  replaceAll :: Text -> Text
  replaceAll = foldr (\(x,y) f -> f . T.replace x y) id replacements

  -- |Get the indentation for a line.
  indent :: Text -> Int
  indent = T.length . T.takeWhile isSpace

  -- |Check if a text is completely blank.
  isBlank :: Text -> Bool
  isBlank = T.all isSpace


(==>) :: a -> b -> (a , b)
(==>) = (,)


--------------------------------------------------------------------------------
-- Constants which are specific to the "Lambek Grishin" => "Lambek" translation.
--------------------------------------------------------------------------------

-- |Set of file paths which should be created for the Lambek calculus.
filesForLambek :: [(FilePath,FilePath)]
filesForLambek =
  ["src/Logic/Lambek/Type.agda"                               ==> "src/Logic/LambekGrishin/Type.agda"
  ,"src/Logic/Lambek/Type/Complexity.agda"                    ==> "src/Logic/LambekGrishin/Type/Complexity.agda"
  ,"src/Logic/Lambek/Type/Context.agda"                       ==> "src/Logic/LambekGrishin/Type/Context.agda"
  ,"src/Logic/Lambek/Type/Context/Polarised.agda"             ==> "src/Logic/LambekGrishin/Type/Context/Polarised.agda"
  ,"src/Logic/Lambek/ResMon.agda"                             ==> "src/Logic/LambekGrishin/ResMon.agda"
  ,"src/Logic/Lambek/ResMon/Judgement.agda"                   ==> "src/Logic/LambekGrishin/ResMon/Judgement.agda"
  ,"src/Logic/Lambek/ResMon/Judgement/Context.agda"           ==> "src/Logic/LambekGrishin/ResMon/Judgement/Context.agda"
  ,"src/Logic/Lambek/ResMon/Judgement/Context/Polarised.agda" ==> "src/Logic/LambekGrishin/ResMon/Judgement/Context/Polarised.agda"
  ,"src/Logic/Lambek/ResMon/Base.agda"                        ==> "src/Logic/LambekGrishin/ResMon/Base.agda"
  ,"src/Logic/Lambek/ResMon/Derivation.agda"                  ==> "src/Logic/LambekGrishin/ResMon/Derivation.agda"
  ,"src/Logic/Lambek/ResMon/Origin.agda"                      ==> "src/Logic/LambekGrishin/ResMon/Origin.agda"
  ,"src/Logic/Lambek/ResMon/Trans.agda"                       ==> "src/Logic/LambekGrishin/ResMon/Trans.agda"
  ]

-- |Set of replacement rules for the Lambek Grishin to Lambek conversion.
replacementListForLambek :: [(Text, Text)]
replacementListForLambek =
  [ "LambekGrishin" ==> "Lambek"
  , "LG"            ==> "NL"
  , "Structural⁺"   ==> "Structural"
  ]


-- |Set of inference rules which may not occur in the Lambek calculus.
blacklistForLambek :: [Text]
blacklistForLambek =
  [ "⊕"      , "⇛"      , "⇚"
--, "mon-⊕"  , "mon-⇛"  , "mon-⇚"
--, "res-⇛⊕" , "res-⊕⇛" , "res-⊕⇚" , "res-⇚⊕"
  , "grish₁" , "grish₂" , "grish₃" , "grish₄"
 ]


--------------------------------------------------------------------------------
-- Constants which are specific to the "Lambek Grishin" => "Linear" translation.
--------------------------------------------------------------------------------

-- |Set of file paths which should be created for the Lambek calculus.
filesForLinear :: [(FilePath, FilePath)]
filesForLinear =
  ["src/Logic/Linear/Type.agda"                                         ==> "src/Logic/LambekGrishin/Type.agda"
  ,"src/Logic/Linear/Type/Complexity.agda"                              ==> "src/Logic/LambekGrishin/Type/Complexity.agda"
  ,"src/Logic/Linear/Type/Context.agda"                                 ==> "src/Logic/LambekGrishin/Type/Context.agda"
  ,"src/Logic/Linear/Type/Context/Polarised.agda"                       ==> "src/Logic/LambekGrishin/Type/Context/Polarised.agda"
  ,"src/Logic/Linear/LambekVanBenthem/Judgement.agda"                   ==> "src/Logic/LambekGrishin/ResMon/Judgement.agda"
  ,"src/Logic/Linear/LambekVanBenthem/Judgement/Context.agda"           ==> "src/Logic/LambekGrishin/ResMon/Judgement/Context.agda"
  ,"src/Logic/Linear/LambekVanBenthem/Judgement/Context/Polarised.agda" ==> "src/Logic/LambekGrishin/ResMon/Judgement/Context/Polarised.agda"
  ]

-- |Set of replacement rules for the Lambek Grishin to Lambek conversion.
replacementListForLinear :: [(Text, Text)]
replacementListForLinear =
  [ "LambekGrishin" ==> "Linear"
  , "LG"            ==> "LL"
  , "ResMon"        ==> "LambekVanBenthem"
  ]


-- |Set of inference rules which may not occur in the Lambek calculus.
blacklistForLinear :: [Text]
blacklistForLinear = blacklistForLambek ++
  [ "⇐"
  ]


--------------------------------------------------------------------------------
-- Constants which are specific to the "Lambek Grishin" => "Unrestricted" translation.
--------------------------------------------------------------------------------

-- |Set of file paths which should be created for the Lambek calculus.
filesForUnrestricted :: [(FilePath, FilePath)]
filesForUnrestricted =
  ["src/Logic/Unrestricted/Type.agda"                        ==> "src/Logic/LambekGrishin/Type.agda"
  ,"src/Logic/Unrestricted/Type/Complexity.agda"             ==> "src/Logic/LambekGrishin/Type/Complexity.agda"
  ,"src/Logic/Unrestricted/Type/Context.agda"                ==> "src/Logic/LambekGrishin/Type/Context.agda"
  ,"src/Logic/Unrestricted/Type/Context/Polarised.agda"      ==> "src/Logic/LambekGrishin/Type/Context/Polarised.agda"
  ,"src/Logic/Unrestricted/Judgement.agda"                   ==> "src/Logic/Linear/NaturalDeduction/Judgement.agda"
  ,"src/Logic/Unrestricted/Structure.agda"                   ==> "src/Logic/Linear/NaturalDeduction/Structure.agda"
  ,"src/Logic/Unrestricted/Structure/Context.agda"           ==> "src/Logic/Linear/NaturalDeduction/Structure/Context.agda"
  ]

-- |Set of replacement rules for the Lambek Grishin to Lambek conversion.
replacementListForUnrestricted :: [(Text, Text)]
replacementListForUnrestricted =
  [ "LambekGrishin"           ==> "Unrestricted"
  , "LG"                      ==> "IL"
  , "Linear.NaturalDeduction" ==> "Unrestricted"
  , "Linear"                  ==> "Unrestricted"
  , "LL"                      ==> "IL"
  ]


-- |Set of inference rules which may not occur in the Lambek calculus.
blacklistForUnrestricted :: [Text]
blacklistForUnrestricted =
  [ "⊕"      , "⇐"      , "⇚"
  , "grish₁" , "grish₂" , "grish₃" , "grish₄"
  ]
