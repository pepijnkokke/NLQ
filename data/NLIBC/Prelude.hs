{-# LANGUAGE GADTs                  #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE RankNTypes             #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE KindSignatures         #-}
{-# LANGUAGE NamedFieldPuns         #-}
{-# LANGUAGE RecordWildCards        #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE PatternSynonyms        #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE AllowAmbiguousTypes    #-}
{-# LANGUAGE ScopedTypeVariables    #-}
{-# LANGUAGE UndecidableInstances   #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE FunctionalDependencies #-}
module NLIBC.Prelude
       (Word,(∷),(<$),($>),lex,lex_,id
       ,S,N,NP,PP,INF,A,IV,TV,Q,NS
       ,bwd,allBwd,parseBwd,module X) where


import           Prelude hiding (Word,abs,lex,not,(*),($),(<$),($>))
import           Control.Arrow (first)
import           Control.Monad (when)
import           Data.Char (isSpace)
import           Data.Maybe (isJust,fromJust)
import           Data.Singletons.Decide ((:~:)(..))
import           Data.Singletons.Prelude (SingI(..))
import           Data.Singletons.Prelude.List ((:++))
import qualified Data.Singletons.Prelude.List as SL
import           NLIBC.Syntax.Base            as X hiding (Q,Atom(..))
import qualified NLIBC.Syntax.Base            as Syn (Atom(..))
import qualified NLIBC.Syntax.Backward        as Bwd
import qualified NLIBC.Syntax.Forward         as Fwd
import           NLIBC.Semantics              as X
import           NLIBC.Semantics.Postulate    as X
import           Text.Parsec
import           Text.Parsec.Token
import           Text.Parsec.Language
import           Text.Parsec.String
import           Language.Haskell.TH (lookupValueName,Exp(..),Lit(..))
import qualified Language.Haskell.TH as TH
import           Language.Haskell.TH.Quote (QuasiQuoter(..))


type S       = El 'Syn.S
type N       = El 'Syn.N
type NP      = El 'Syn.NP
type PP      = El 'Syn.PP
type INF     = El 'Syn.INF
type A       = N  :← N
type IV      = NP :→ S
type TV      = IV :← NP
type Q a b c = UnitR KHol (c :⇦ (a :⇨ b))
type NS      = Q NP S S


type Word  a = Entry (StI a)
data Entry x = Entry (SStructI x) (Extern (HI x))

infix 1 ∷

(∷) :: Name -> Univ a -> Extern a
n ∷ a = extern a (PRIM(Prim a n))

lex_ :: SingI a => Extern (H a) -> Entry (StI a)
lex_ f = Entry (SStI sing) f

lex :: SingI a => Name -> Entry (StI a)
lex n = let x = sing in Entry (SStI x) (n ∷ (h x))

instance Show (Entry x) where
  show (Entry x f) = show (intern (hi x) f)

(<$) :: Entry (StI (b :← a)) -> Entry (StI a) -> Entry (StI b)
(Entry (SStI (b :%← _)) f) <$ (Entry (SStI _) x) = Entry (SStI b) (f x)

($>) :: Entry (StI a) -> Entry (StI (a :→ b)) -> Entry (StI b)
(Entry (SStI _) x) $> (Entry (SStI (_ :%→ b)) f) = Entry (SStI b) (f x)


-- ** Backward-Chaining Proof Search

class Combine a b | a -> b where
  combine :: a -> b

instance Combine (Entry t) (Entry t) where
  combine = id

instance (Combine x (Entry a)) => Combine [x] (Entry (DIA KRes a)) where
  combine [x] = case combine x of (Entry a r) -> Entry (SDIA SKRes a) r

instance (Combine x1 (Entry a1), Combine x2 (Entry a2))
         => Combine (x1,x2) (Entry (a1 :∙ a2)) where
  combine (x1,x2) = case (combine x1,combine x2) of
    (Entry x f, Entry y g) -> withHI x (withHI y (Entry (x :%∙ y) (f, g)))


-- ** Type and DSL for lexicon entries

parseBwd :: Combine x (Entry a) => String -> SType b -> x -> IO ()
parseBwd str b e1 = do
  let
    Entry x e2 = combine e1
    seq        = x :%⊢ SStO b
    exprsNL    = Bwd.findAll seq
    exprsHS    = map (\f -> runHask (eta seq f) Nil $ intern (hi x) e2) exprsNL
  if null exprsNL
    then putStr "\x1b[31m"
    else putStr "\x1b[32m"
  putStrLn str
  print (length exprsNL)
  mapM_ print exprsHS
  putStrLn "\x1b[0m"


-- ** QuasiQuoter for Backward-Chaining Proof Search

parseTree :: String -> Either ParseError (TH.Q Exp)
parseTree = parse (whiteSpace *> pTree1) ""
  where
    TokenParser{whiteSpace,identifier,parens,angles} = makeTokenParser haskellStyle
    LanguageDef{reservedNames} = haskellDef

    pTree1 :: Parser (TH.Q Exp)
    pTree1 = tuple <$> many1 (pWord <|> pReset <|> parens pTree1)
      where
      tuple :: [TH.Q Exp] -> TH.Q Exp
      tuple xs = do xs <- sequence xs
                    return (foldr1 (\x y -> TupE [x,y]) xs)

    pReset :: Parser (TH.Q Exp)
    pReset = reset <$> angles pTree1
      where
      reset :: TH.Q Exp -> TH.Q Exp
      reset x = ListE . (:[]) <$> x

    pWord  :: Parser (TH.Q Exp)
    pWord  = do x <- identifier
                let x' = if x `elem` reservedNames then x++"_" else x
                let xn = lookupValueName x'
                    go :: Maybe TH.Name -> TH.Q Exp
                    go (Just xn) = return (VarE xn)
                    go  Nothing  = fail ("unknown name '"++x'++"'")
                return (xn >>= go)


bwd :: QuasiQuoter
bwd = QuasiQuoter
  { quoteExp = bwd, quotePat = undefined, quoteType = undefined, quoteDec = undefined }
  where
    -- generate `parseBwd $(strExp) S $(treeExp)`
    bwd str =
      AppE (AppE (AppE (VarE 'parseBwd) strExp)
            (AppE (ConE 'SEl) (ConE 'SS))) <$> treeExp
      where
      treeExp = case parseTree str of
        Left  err -> fail (show err)
        Right exp -> exp

      strExp = LitE (StringL (fixWS (dropWhile isSpace str)))
        where
        fixWS :: String -> String
        fixWS [] = []
        fixWS (' ':' ':xs) = fixWS (' ':xs)
        fixWS ('(':    xs) = fixWS xs
        fixWS (')':    xs) = fixWS xs
        fixWS ('<':    xs) = fixWS xs
        fixWS ('>':    xs) = fixWS xs
        fixWS ( x :    xs) = x : fixWS xs


allBwd :: TH.Q Exp
allBwd = do
  bwds1 <- traverse lookupValueName (map (("bwd"++).show) [0..23])
  let bwds2 = map (VarE . fromJust) (takeWhile isJust bwds1)
  return (AppE (VarE 'sequence_) (ListE bwds2))


-- ** Forward-Chaining Proof Search (Experimental)
{-
parseFwd :: SType b -> Entries xs ->  IO ()
parseFwd (b :: SType b) (xs :: Entries xs) = do
  let
    prfs1 :: [Fwd.TypedBy xs b]
    prfs1 = Fwd.findAll (typeofs xs) b
    prfs2 :: [String]
    prfs2 = map go prfs1

    go (Fwd.TypedBy x Refl f) =
      case joinTree x xs of
      Entry _ g -> show (runHask (abs (eta (x :%⊢ SStO b) f)) (Cons g Nil))

  print (length prfs2)
  mapM_ putStrLn prfs2

infixr 4 ∷; (∷) = SCons; (·) = SNil

data Entries (xs :: [StructI]) where
  SNil  :: Entries '[]
  SCons :: Entry x -> Entries xs -> Entries (x ': xs)

typeofs :: Entries xs -> SL.SList xs
typeofs  SNil                  = SL.SNil
typeofs (SCons (Entry x _) xs) = SL.SCons x (typeofs xs)

joinTree :: SStructI x -> Entries (ToList x) -> Entry x
joinTree (SStI a) (SCons x SNil) = x
joinTree (SDIA k x) env = entryDIA k (joinTree x env)
  where
    entryDIA :: SKind k -> Entry x -> Entry (DIA k x)
    entryDIA k (Entry x r) = Entry (SDIA k x) r
joinTree (SPROD k x y) env = entryPROD k (joinTree x xs) (joinTree y ys)
  where
    (xs,ys) = sBreak (fromJust (sToList x)) env
    sBreak :: SL.SList xs -> Entries (xs :++ ys) -> (Entries xs, Entries ys)
    sBreak  SL.SNil                 env  = (SNil, env)
    sBreak (SL.SCons _ xs) (SCons x env) = first (SCons x) (sBreak xs env)
    entryPROD :: SKind k -> Entry x -> Entry y -> Entry (PROD k x y)
    entryPROD k (Entry x f) (Entry y g)  =
      Entry (SPROD k x y) (withHI x (withHI y (pair(f,g))))

-- -}
-- -}
-- -}
-- -}
-- -}