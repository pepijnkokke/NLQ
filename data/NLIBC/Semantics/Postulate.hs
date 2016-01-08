{-# LANGUAGE GADTs #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
module NLIBC.Semantics.Postulate where


import           Prelude hiding (($),(!!),abs,lookup)
import           Control.Monad.Supply
import qualified NLIBC.Syntax.Base as NL
import           NLIBC.Syntax.Base
import           Data.Set (Set)
import qualified Data.Set as Set
import           Data.Singletons.Decide
import           Data.Singletons.Prelude
import           Data.Singletons.TH (promote,singletons)
import           Text.Printf (printf)
import           Unsafe.Coerce (unsafeCoerce)


-- ** Semantic Types

infixr 4 :*
infixr 2 :->

data E
data T

data Univ (t :: *) where
  E     :: Univ E
  T     :: Univ T
  Unit  :: Univ ()
  (:->) :: Univ a -> Univ b -> Univ (a -> b)
  (:*)  :: Univ a -> Univ b -> Univ (a  , b)


class    UnivI t  where univ :: Univ t
instance UnivI E  where univ = E
instance UnivI T  where univ = T
instance UnivI () where univ = Unit

instance (UnivI a, UnivI b) => UnivI (a -> b) where univ = univ :-> univ
instance (UnivI a, UnivI b) => UnivI (a  , b) where univ = univ :*  univ

-- ** Semantic Expressions

infixl 9 :$, $

type Name = String

data Prim (a :: *) where
  Prim   :: Univ a -> Name -> Prim a
  (:$)   :: Prim (a -> b) -> Expr a -> Prim b
  CaseOf :: Expr (a  , b) -> Expr (b -> a -> c) -> Prim c

type family EXPR (a :: *) where
  EXPR (a -> b) = (Expr a -> Expr b)
  EXPR (a  , b) = (Expr a  , Expr b)
  EXPR ()       = ()
  EXPR E        = E
  EXPR T        = T

data Expr (a :: *) where
  PRIM :: Prim a -> Expr a
  EXPR :: UnivI a => EXPR a -> Expr a


-- |Function application, normalising if possible.
($) :: Expr (a -> b) -> Expr a -> Expr b
EXPR f $ x =      (f    x)
PRIM f $ x = PRIM (f :$ x)


-- |Case analysis, normalising if possible.
caseof :: Expr (a  , b) -> Expr (b -> a -> c) -> Expr c
caseof (EXPR (x, y)) (EXPR f) = case f y of { EXPR g -> g x ; PRIM g -> PRIM (g :$ x) }
caseof xy            f        = PRIM (CaseOf xy f)


-- ** Type Reconstruction

class TypeOf (f :: * -> *) where
  typeof :: f a -> Univ a

instance TypeOf (Prim) where
  typeof (Prim t _)   = t
  typeof (f :$ _)     = case typeof f of (_ :-> b)       -> b
  typeof (CaseOf _ f) = case typeof f of (_ :-> _ :-> c) -> c

instance TypeOf (Expr) where
  typeof (PRIM p) = typeof p
  typeof (EXPR e) = univ


-- ** Haskell Expressions with Environments

newtype Hask ts t = Hask { runHask :: Env ts -> Expr t }

data Env (ts :: [*]) where
  Nil  :: Env '[]
  Cons :: Expr t -> Env ts -> Env (t ': ts)

singletons [d|
  data Nat = Zero | Suc Nat
     deriving (Eq,Show,Ord)
  |]

n0 = SZero
n1 = SSuc n0
n2 = SSuc n1
n3 = SSuc n2
n4 = SSuc n3
n5 = SSuc n4
n6 = SSuc n5
n7 = SSuc n6
n8 = SSuc n7
n9 = SSuc n8

promote [d|
  (!!) :: [a] -> Nat -> a
  []     !! _     = error "!!: index out of bounds"
  (x:_ ) !! Zero  = x
  (x:xs) !! Suc n = xs !! n
  |]

lookup :: SNat n -> Env ts -> Expr (ts :!! n)
lookup  _        Nil        = error "%!!: index out of bounds"
lookup  SZero   (Cons x _ ) = x
lookup (SSuc n) (Cons x xs) = lookup n xs


-- * "Smart" constructors

--(:::) :: Name -> Univ t -> Expr t
pattern n ::: t = PRIM(Prim t n)

not :: Expr T -> Expr T
not x = Not x

lam :: (UnivI a, UnivI b) => EXPR (a -> b) -> Expr (a -> b)
lam = EXPR

unit :: Expr ()
unit = EXPR ()

pair :: (UnivI a, UnivI b) => EXPR (a , b) -> Expr (a , b)
pair = EXPR

exists :: UnivI t => Univ t -> EXPR (t -> T) -> Expr T
exists t x = Exists t x

forall :: UnivI t => Univ t -> EXPR (t -> T) -> Expr T
forall t x = ForAll t x

-- ** Pretty-Printing Expressions

infix  6 :/=, :==
infixr 4 :/\
infixr 2 :=>

pattern x :/= y = x :≢ y
pattern x :== y = x :≡ y
pattern x :/\ y = x :∧ y
pattern x :=> y = x :⊃ y


infix  6 :≢, :≡
infixr 4 :∧
infixr 2 :⊃

pattern x :≢ y     = Not (x :≡ y)
pattern x :≡ y     = PRIM (Prim (E :-> E :-> T)   "≡" :$ x :$ y)
pattern Not  x     = PRIM (Prim (T :-> T)         "¬" :$ x)
pattern x :∧ y     = PRIM (Prim (T :-> T :-> T)   "∧" :$ x :$ y)
pattern x :⊃ y     = PRIM (Prim (T :-> T :-> T)   "⊃" :$ x :$ y)
pattern ForAll t f = PRIM (Prim ((t :-> T) :-> T) "∀" :$ EXPR f)
pattern Exists t f = PRIM (Prim ((t :-> T) :-> T) "∃" :$ EXPR f)


ppPrim :: Int -> Prim a -> Supply Name String
ppPrim d (Prim _ n)    = return n
ppPrim d (f :$ x)      = parens (d > 10) (printf "%s %s" <$> ppPrim 10 f <*> ppExpr 11 x)
ppPrim d (CaseOf xy f) = do x <- supply
                            y <- supply
                            case typeof xy of
                              (a :* b) -> do
                                let x' = PRIM (Prim a x)
                                let y' = PRIM (Prim b y)
                                let f' = (f $ y') $ x'
                                parens (d > 1)
                                  (printf "case %s of (%s,%s) -> %s" <$>
                                    ppExpr 0 xy <*> pure x <*> pure y <*> ppExpr 2 f')


ppExpr :: Int -> Expr a -> Supply Name String
ppExpr d (ForAll t f)         = do x <- supply
                                   parens (d > 1)
                                     (printf "∀%s.%s" x <$> ppExpr 2 (f (PRIM (Prim t x))))
ppExpr d (Exists t f)         = do x <- supply
                                   parens (d > 1)
                                     (printf "∃%s.%s" x <$> ppExpr 2 (f (PRIM (Prim t x))))
ppExpr d (u :≢ v)             = parens (d > 6)  (printf "%s ≢ %s" <$> ppExpr 7 u <*> ppExpr 7 v)
ppExpr d (Not  u)             = parens (d > 8)  (printf    "¬ %s" <$> ppExpr 8 u)
ppExpr d (u :≡ v)             = parens (d > 6)  (printf "%s ≡ %s" <$> ppExpr 7 u <*> ppExpr 7 v)
ppExpr d (u :∧ v)             = parens (d > 2)  (printf "%s ∧ %s" <$> ppExpr 3 u <*> ppExpr 2 v)
ppExpr d (u :⊃ v)             = parens (d > 4)  (printf "%s ⊃ %s" <$> ppExpr 5 u <*> ppExpr 4 v)
ppExpr d (PRIM f)             = ppPrim d f
ppExpr d (EXPR f :: Expr a) = ppEXPR d (univ :: Univ a) f
  where
    ppEXPR :: Int -> Univ a -> EXPR a -> Supply Name String
    ppEXPR d (a :-> b) f       = do x <- supply
                                    parens (d > 1)
                                      (printf "λ%s.%s" x <$> ppExpr d (f (PRIM (Prim a x))))
    ppEXPR d (a :*  b) (x , y) = do printf "(%s,%s)" <$> ppExpr 0 x <*> ppExpr 0 y
    ppEXPR d Unit      ()      = return "()"


-- |Wrap parenthesis around an expression under a functor, if a
--  Boolean flag is true.
parens :: (Functor f) => Bool -> f String -> f String
parens b s = if b then printf "(%s)" <$> s else s


instance Show (Prim t) where
  show = show . PRIM

instance Show (Expr t) where
  show x = evalSupply (ppExpr 0 x) ns
    where
      ns :: [Name]
      ns = [ x | n <- [0..], let x = 'x':show n ]
