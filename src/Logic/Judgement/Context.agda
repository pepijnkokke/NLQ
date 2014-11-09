------------------------------------------------------------------------
-- The Lambek Calculus in Agda
--
------------------------------------------------------------------------


open import Category
open import Algebra using (module Monoid; Monoid)
open import Function using (_∘_)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Data.Unit using (⊤; tt)
open import Relation.Nullary using (Dec; yes; no)
open import Relation.Binary.PropositionalEquality as P using (_≡_; refl)


module Logic.Judgement.Context
  {ℓ} (Type : Set ℓ) (Context : Set ℓ)
  (_[_]′ : Context → Type → Type)
  (_<_>′ : Context → Context → Context)
  where


open import Logic.Judgement Type Type


infix 5 _<⊢_ _⊢>_

data JudgementContext : Set ℓ where
  _<⊢_ : Context → Type → JudgementContext
  _⊢>_ : Type → Context → JudgementContext


-- Proofs which show that constructors of judgement contexts (as all
-- Agda data-constructors) respect equality.

<⊢-injective : ∀ {I J K L} → I <⊢ J ≡ K <⊢ L → I ≡ K × J ≡ L
<⊢-injective refl = refl , refl

⊢>-injective : ∀ {I J K L} → I ⊢> J ≡ K ⊢> L → I ≡ K × J ≡ L
⊢>-injective refl = refl , refl


-- Apply a context to a type by plugging the type into the context.
_[_] : JudgementContext → Type → Judgement
(A <⊢ B) [ C ] = A [ C ]′ ⊢ B
(A ⊢> B) [ C ] = A ⊢ B [ C ]′

-- Insert a context into a judgement context
_<_> : JudgementContext → Context → JudgementContext
_<_> (A <⊢ B) C = A < C >′ <⊢ B
_<_> (A ⊢> B) C = A ⊢> B < C >′
