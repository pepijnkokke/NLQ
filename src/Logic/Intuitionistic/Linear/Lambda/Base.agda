------------------------------------------------------------------------
-- The Lambek Calculus in Agda
------------------------------------------------------------------------


open import Algebra                                    using (module Monoid)
open import Function                                   using (_∘_)
open import Data.List                                  using (List; _++_) renaming ([] to ∅; _∷_ to _,_)
open import Data.Product                               using (∃; ∃₂; _×_; _,_; proj₁; proj₂)
open import Relation.Nullary                           using (Dec; yes; no)
open import Relation.Binary                            using (DecSetoid)
open import Relation.Binary.PropositionalEquality as P using (_≡_; refl; sym; subst; subst₂)


module Logic.Intuitionistic.Linear.Lambda.Base {ℓ} (Univ : Set ℓ) where


open import Logic.Intuitionistic.Linear.Lambda.Type      Univ
open import Logic.Intuitionistic.Linear.Lambda.Judgement Univ
open Monoid (Data.List.monoid Type) using (identity; assoc)

infix 1 Λ_

data Λ_ : Judgement → Set ℓ where

  ax  : ∀ {A}
      → Λ A , ∅ ⊢ A

  ⇒ᵢ  : ∀ {Γ₁ A B}
      → Λ A , Γ₁ ⊢ B
      → Λ     Γ₁ ⊢ A ⇒ B

  ⇒ₑ  : ∀ {Γ₁ Γ₂ A B}
      → Λ Γ₁       ⊢ A ⇒ B
      → Λ       Γ₂ ⊢ A
      → Λ Γ₁ ++ Γ₂ ⊢ B

  ⊗ᵢ  : ∀ {Γ₁ Γ₂ A B}
      → Λ Γ₁       ⊢ A
      → Λ       Γ₂ ⊢ B
      → Λ Γ₁ ++ Γ₂ ⊢ A ⊗ B

  ⊗ₑ  : ∀ {Γ₁ Γ₂ A B C}
      → Λ          Γ₁        ⊢ A ⊗ B
      → Λ A , (B ,       Γ₂) ⊢ C
      → Λ          Γ₁ ++ Γ₂  ⊢ C

  eᴸ  : ∀ Γ₁ Γ₂ Γ₃ Γ₄ {A}
      → Λ (Γ₁ ++ Γ₃) ++ (Γ₂ ++ Γ₄) ⊢ A
      → Λ (Γ₁ ++ Γ₂) ++ (Γ₃ ++ Γ₄) ⊢ A


-- Proof: weakening follows easily by induction from the simplified
-- version of weakening assumed above.
-- Proof: contraction of identical contexts follows easily by
-- induction from the derived rules for contaction above.
-- Lemma: weaker versions of eᴸ which only swap the first two
-- (or three) elements are often useful.
eᴸ₁  : ∀ {Γ A B C}
     → Λ B , (A , Γ) ⊢ C
     → Λ A , (B , Γ) ⊢ C
eᴸ₁  = eᴸ ∅ (_ , ∅) (_ , ∅) _

eᴸ₂  : ∀ {Γ A B C D}
     → Λ C , (A , (B , Γ)) ⊢ D
     → Λ A , (B , (C , Γ)) ⊢ D
eᴸ₂  = eᴸ ∅ (_ , (_ , ∅)) (_ , ∅) _


-- Lemma: weaker version of eᴸ and eᴿ which only swap two contexts,
-- without allowing them to be embedded in further contexts are often
-- useful as well.
sᴸ  : ∀ (Γ₁ : List Type) {Γ₂ : List Type} {A} → Λ Γ₂ ++ Γ₁ ⊢ A → Λ Γ₁ ++ Γ₂ ⊢ A
sᴸ  Γ₁ {∅ } = subst  (λ Γ       → Λ       Γ   ⊢ _)                   (sym (proj₂ identity Γ₁))
sᴸ  ∅  {Γ₂} = subst  (λ     Γ   → Λ Γ         ⊢ _)                                             (proj₂ identity Γ₂)
sᴸ  Γ₁ {Γ₂} = subst₂ (λ Γ₁′ Γ₂′ → Λ Γ₂ ++ Γ₁′ ⊢ _ → Λ Γ₁ ++ Γ₂′ ⊢ _) (     proj₂ identity Γ₁ ) (proj₂ identity Γ₂) (eᴸ  ∅ Γ₁ Γ₂ ∅)


-- Lemma: introduction and elimination of right-handed empty context.
∅ᵢ : ∀ {Γ A} → Λ Γ      ⊢ A → Λ Γ ++ ∅ ⊢ A
∅ᵢ {Γ} f rewrite proj₂ identity Γ = f
∅ₑ : ∀ {Γ A} → Λ Γ ++ ∅ ⊢ A → Λ Γ      ⊢ A
∅ₑ {Γ} f rewrite proj₂ identity Γ = f