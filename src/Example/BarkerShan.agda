------------------------------------------------------------------------
-- The Lambek Calculus in Agda
------------------------------------------------------------------------


open import Function using (_$_)
open import Example.System.NLCL


module Example.BarkerShan where


MARY_LEFT₀ : NL dp ⊗ (dp ⇒ s) ⊢ s
MARY_LEFT₀ = r⇒⊗ ax′
mary_left₀ : ⟦ s ⟧ᵀ
mary_left₀ = [ MARY_LEFT₀ ]ᵀ (mary , left)
--> LEFT mary


JOHN_LOVES_EVERYONE₀ : NL dp ⊗ (dp ⇒ s) ⇐ dp ⊗ s ⇦ (dp ⇨ s) ⊢ s
JOHN_LOVES_EVERYONE₀ = r⇒⊗ (r⇒⊗ (Iᵢ (r⊗⇒ (Lᵢ (r⊗⇒ (Lᵢ (r⇦∘ (m⇦ ax′ (r∘⇨ (Lₑ (r⇒⊗ (Lₑ (r⇒⊗ (Iₑ (r⊗⇒ (r⇐⊗ ax′))))))))))))))))
john_loves_everyone₀ : ⟦ s ⟧ᵀ
john_loves_everyone₀ = [ JOHN_LOVES_EVERYONE₀ ]ᵀ (john , (loves , everyone))
--> forAll (λ x → PERSON x ⊃ john LOVES x)
