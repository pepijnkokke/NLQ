------------------------------------------------------------------------
-- The Lambek Calculus in Agda
------------------------------------------------------------------------

open import Data.Bool using (Bool; true; false; _∧_; _∨_)
open import Data.List using (List; _∷_; [])
open import Function using (id)
open import Reflection using (Term)
open import Example.System.fLG


module Example.MaryThinksSomeoneLeft where


MARY_THINKS_SOMEONE_LEFT₀ : LG · np · ⊗ (· (np ⇒ s⁻) ⇐ s⁻ · ⊗ (· (np ⇐ n) ⊗ n · ⊗ · np ⇒ s⁻ ·)) ⊢[ s⁻ ]
MARY_THINKS_SOMEONE_LEFT₀
  = ⇁ (r⇒⊗ (r⇐⊗ (↼ (⇐ᴸ (⇁ (r⇐⊗ (⊗ᴸ (r⇐⊗ (↼ (⇐ᴸ ax⁺ (↽ (r⊗⇐ (r⇒⊗ (↼ (⇒ᴸ ax⁺ ax⁻))))))))))) (⇒ᴸ ax⁺ ax⁻)))))
mary_thinks_someone_left₀ : ⟦ s⁻ ⟧ᵀ
mary_thinks_someone_left₀
  = [ MARY_THINKS_SOMEONE_LEFT₀ ]ᵀ (mary , thinks , someone , left , ∅)

LIST_mary_thinks_someone_left₀ : List Term
LIST_mary_thinks_someone_left₀
  = quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → k (THINKS mary (exists (λ x → PERSON x ∧ LEFT x)))))
  ∷ quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → k (exists (λ x → PERSON x ∧ THINKS mary (LEFT x)))))
  ∷ quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → exists (λ x → PERSON x ∧ k (THINKS mary (LEFT x)))))
  ∷ []
TEST_mary_thinks_someone_left₀ : Assert (quoteTerm mary_thinks_someone_left₀ ∈ LIST_mary_thinks_someone_left₀)
TEST_mary_thinks_someone_left₀ = _


MARY_THINKS_SOMEONE_LEFT₁ : LG · np · ⊗ (· (np ⇒ s⁻) ⇐ s⁻ · ⊗ (· (np ⇐ n) ⊗ n · ⊗ · np ⇒ s⁻ ·)) ⊢[ s⁻ ]
MARY_THINKS_SOMEONE_LEFT₁
  = ⇁ (r⇒⊗ (r⇒⊗ (r⇐⊗ (⊗ᴸ (r⇐⊗ (↼ (⇐ᴸ ax⁺ (↽ (r⊗⇐ (r⊗⇒ (r⇐⊗ (↼ (⇐ᴸ (⇁ (r⇒⊗ (↼ (⇒ᴸ ax⁺ ax⁻)))) (⇒ᴸ ax⁺ ax⁻))))))))))))))
mary_thinks_someone_left₁ : ⟦ s⁻ ⟧ᵀ
mary_thinks_someone_left₁
  = [ MARY_THINKS_SOMEONE_LEFT₁ ]ᵀ (mary , thinks , someone , left , ∅)

LIST_mary_thinks_someone_left₁ : List Term
LIST_mary_thinks_someone_left₁
  = quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → k (THINKS mary (exists (λ x → PERSON x ∧ LEFT x)))))
  ∷ quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → k (exists (λ x → PERSON x ∧ THINKS mary (LEFT x)))))
  ∷ quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → exists (λ x → PERSON x ∧ k (THINKS mary (LEFT x)))))
  ∷ []
TEST_mary_thinks_someone_left₁ : Assert (quoteTerm mary_thinks_someone_left₁ ∈ LIST_mary_thinks_someone_left₁)
TEST_mary_thinks_someone_left₁ = _


MARY_THINKS_SOMEONE_LEFT₂ : LG · np · ⊗ (· (np ⇒ s⁻) ⇐ s⁻ · ⊗ (· (np ⇐ n) ⊗ n · ⊗ · np ⇒ s⁻ ·)) ⊢[ s⁻ ]
MARY_THINKS_SOMEONE_LEFT₂
  = ⇁ (r⇒⊗ (r⇒⊗ (r⇐⊗ (⊗ᴸ (r⊗⇐ (r⊗⇒ (r⇐⊗ (↼ (⇐ᴸ (⇁ (r⇐⊗ (r⇐⊗ (↼ (⇐ᴸ ax⁺ (↽ (r⊗⇐ (r⇒⊗ (↼ (⇒ᴸ ax⁺ ax⁻)))))))))) (⇒ᴸ ax⁺ ax⁻))))))))))
mary_thinks_someone_left₂ : ⟦ s⁻ ⟧ᵀ
mary_thinks_someone_left₂
  = [ MARY_THINKS_SOMEONE_LEFT₂ ]ᵀ (mary , thinks , someone , left , ∅)

LIST_mary_thinks_someone_left₂ : List Term
LIST_mary_thinks_someone_left₂
  = quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → k (THINKS mary (exists (λ x → PERSON x ∧ LEFT x)))))
  ∷ quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → k (exists (λ x → PERSON x ∧ THINKS mary (LEFT x)))))
  ∷ quoteTerm (id {A = ⟦ s⁻ ⟧ᵀ} (λ k → exists (λ x → PERSON x ∧ k (THINKS mary (LEFT x)))))
  ∷ []
TEST_mary_thinks_someone_left₂ : Assert (quoteTerm mary_thinks_someone_left₂ ∈ LIST_mary_thinks_someone_left₂)
TEST_mary_thinks_someone_left₂ = _
