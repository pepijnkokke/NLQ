------------------------------------------------------------------------
-- The Lambek Calculus in Agda
--
------------------------------------------------------------------------


open import Data.Nat as Nat using (ℕ; suc; zero; _+_; _<_; _≮_; _≥_; s≤s; z≤n)
open import Data.Nat.Properties as NatProps using ()
open import Relation.Binary using (module StrictTotalOrder)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl; cong)


module Logic.Classical.Ordered.LambekGrishin.Type.Complexity {ℓ} (Atom : Set ℓ) where


open import Logic.Classical.Ordered.LambekGrishin.Type Atom
open StrictTotalOrder NatProps.strictTotalOrder using (irrefl)


infix 10 ⌈_⌉ ⌊_⌋

-- Compute the complexity of a type, measured in the number of
-- connectives and atomic formulas in the type.
mutual
  ⌈_⌉ : Type → ℕ
  ⌈ A ⌉ = suc ⌊ A ⌋

  ⌊_⌋ : Type → ℕ
  ⌊ el  A ⌋ = zero
  ⌊ □   A ⌋ = ⌈ A ⌉
  ⌊ ◇   A ⌋ = ⌈ A ⌉
  ⌊ ₀   A ⌋ = ⌈ A ⌉
  ⌊ A   ⁰ ⌋ = ⌈ A ⌉
  ⌊ ₁   A ⌋ = ⌈ A ⌉
  ⌊ A   ¹ ⌋ = ⌈ A ⌉
  ⌊ A ⊗ B ⌋ = ⌈ A ⌉ + ⌈ B ⌉
  ⌊ A ⇚ B ⌋ = ⌈ A ⌉ + ⌈ B ⌉
  ⌊ A ⇛ B ⌋ = ⌈ A ⌉ + ⌈ B ⌉
  ⌊ A ⊕ B ⌋ = ⌈ A ⌉ + ⌈ B ⌉
  ⌊ A ⇐ B ⌋ = ⌈ A ⌉ + ⌈ B ⌉
  ⌊ A ⇒ B ⌋ = ⌈ A ⌉ + ⌈ B ⌉


-- Lemma which shows that if types are not of the same complexity,
-- then they cannot be equal.
⌈A⌉<⌈B⌉→A≠B : ∀ A B → ⌈ A ⌉ < ⌈ B ⌉ → A ≢ B
⌈A⌉<⌈B⌉→A≠B A B ⌈A⌉<⌈B⌉ A=B = irrefl (cong ⌈_⌉ A=B) ⌈A⌉<⌈B⌉
