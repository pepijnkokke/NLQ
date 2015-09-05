--------------------------------------------------------------------------------
-- The Lambek Calculus in Agda
--
-- This file was generated from:
--   src/Logic/LG/ToAgda.agda
--------------------------------------------------------------------------------


open import Function     using (id; _∘_)
open import Data.Product using (_×_; _,_; proj₁; proj₂; uncurry)
open import Relation.Binary.PropositionalEquality as P


module Logic.NLCPS.ToAgda
  {a ℓ} (Atom : Set a) (R : Set ℓ) (⌈_⌉ᵁ : Atom → Set ℓ) where


open import Logic.Polarity
open import Logic.Translation
open import Logic.NLCPS.Type                Atom
open import Logic.NLCPS.Structure.Polarised Atom
open import Logic.NLCPS.Sequent           Atom
open import Logic.NLCPS.Base                Atom


private
  infix 3 ¬_

  ¬_ : Set ℓ → Set ℓ
  ¬ A = A → R

  deMorgan : {A B : Set ℓ} → (¬ ¬ A) → (¬ ¬ B) → ¬ ¬ (A × B)
  deMorgan c₁ c₂ k = c₁ (λ x → c₂ (λ y → k (x , y)))


-- * Call-by-value translation

private
  ⌈_⌉ᵗ : Type → Set ℓ
  ⌈ el  A ⌉ᵗ =      ⌈ A ⌉ᵁ
  ⌈ ◇   A ⌉ᵗ =      ⌈ A ⌉ᵗ
  ⌈ A ⊗ B ⌉ᵗ =   (  ⌈ A ⌉ᵗ ×   ⌈ B ⌉ᵗ)
  ⌈ A ⇒ B ⌉ᵗ =   (¬ ⌈ B ⌉ᵗ → ¬ ⌈ A ⌉ᵗ)
  ⌈ B ⇐ A ⌉ᵗ =   (¬ ⌈ B ⌉ᵗ → ¬ ⌈ A ⌉ᵗ)
  ⌈_⌉ˢ_ : ∀ {p} → Structure p → Polarity → Set ℓ
  ⌈ X ⌉ˢ q = flatten (λ { + A → ⌈ A ⌉ᵗ ; - A → ¬ ⌈ A ⌉ᵗ }) q X
    where
      flatten : ∀ {p} (f : Polarity → Type → Set ℓ) (q : Polarity) (X : Structure p) → Set ℓ
      flatten f + ·  A  · = f + A
      flatten f - ·  A  · = f - A
      flatten f _ ⟨  X  ⟩ = flatten f + X
      flatten f _ (X ⊗ Y) = flatten f + X × flatten f + Y
      flatten f _ (X ⇒ Y) = flatten f + X × flatten f - Y
      flatten f _ (X ⇐ Y) = flatten f - X × flatten f + Y

  ⌈_⌉ʲ : Sequent → Set ℓ
  ⌈   X  ⊢  Y   ⌉ʲ = ⌈ X ⌉ˢ + → ⌈ Y ⌉ˢ - → R
  ⌈ [ A ]⊢  Y   ⌉ʲ = ⌈ Y ⌉ˢ - →   ¬ ⌈ A ⌉ᵗ
  ⌈   X  ⊢[ B ] ⌉ʲ = ⌈ X ⌉ˢ + → ¬ ¬ ⌈ B ⌉ᵗ


  ⌈_⌉ : ∀ {J} → NLCPS J → ⌈ J ⌉ʲ
  ⌈ ax⁺     ⌉ x y = y x
  ⌈ ax⁻     ⌉ x y = x y
  ⌈ ⇁   f   ⌉ x y = ⌈ f ⌉ x y
  ⌈ ↽   f   ⌉ x y = ⌈ f ⌉ y x
  ⌈ ⇀   f   ⌉ x y = ⌈ f ⌉ x y
  ⌈ ↼   f   ⌉ x y = ⌈ f ⌉ y x
  ⌈ ◇ᴸ  f   ⌉ x y = ⌈ f ⌉ x y
  ⌈ ◇ᴿ  f   ⌉ x y = ⌈ f ⌉ x y
  ⌈ ⊗ᴸ  f   ⌉ x y = ⌈ f ⌉ x y
  ⌈ ⊗ᴿ  f g ⌉ (x , y) k = deMorgan (⌈ f ⌉ x) (⌈ g ⌉ y) k
  ⌈ ⇒ᴸ  f g ⌉ (x , y) k = deMorgan (λ k → k (⌈ g ⌉ y)) (⌈ f ⌉ x) (uncurry k)
  ⌈ ⇒ᴿ  f   ⌉ x k = k (λ y z → ⌈ f ⌉ x (z , y))
  ⌈ ⇐ᴸ  f g ⌉ (x , y) k = deMorgan (λ k → k (⌈ g ⌉ x)) (⌈ f ⌉ y) (uncurry k)
  ⌈ ⇐ᴿ  f   ⌉ x k = k (λ y z → ⌈ f ⌉ x (y , z))
  ⌈ r⇒⊗ f   ⌉ (x , y) z = ⌈ f ⌉ y (x , z)
  ⌈ r⊗⇒ f   ⌉ x (y , z) = ⌈ f ⌉ (y , x) z
  ⌈ r⇐⊗ f   ⌉ (x , y) z = ⌈ f ⌉ x (z , y)
  ⌈ r⊗⇐ f   ⌉ x (y , z) = ⌈ f ⌉ (x , z) y
CBV : Translation Type (Set ℓ) NLCPS_ id
CBV = record { ⟦_⟧ᵗ = ⌈_⌉ᵗ ; ⟦_⟧ʲ = ⌈_⌉ʲ ; [_]  = ⌈_⌉ }
