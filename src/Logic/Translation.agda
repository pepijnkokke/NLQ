------------------------------------------------------------------------
-- The Lambek Calculus in Agda
------------------------------------------------------------------------

open import Level    using (suc; _⊔_)
open import Function using (_∘_)


module Logic.Translation where


record Translation {j₁ j₂ t₁ t₂ ℓ₁ ℓ₂}
                   {Sequent₁ : Set j₁}
                   {Sequent₂ : Set j₂}
                   (Type₁ : Set ℓ₁)
                   (Type₂ : Set ℓ₂)
                   (Term₁ : Sequent₁ → Set t₁)
                   (Term₂ : Sequent₂ → Set t₂)
                   : Set (suc (j₁ ⊔ j₂ ⊔ t₁ ⊔ t₂ ⊔ ℓ₁ ⊔ ℓ₂)) where
  field
    ⟦_⟧ᵗ : Type₁ → Type₂
    ⟦_⟧ʲ : Sequent₁ → Sequent₂
    [_]  : {J : Sequent₁} → Term₁ J → Term₂ ⟦ J ⟧ʲ


infixr 9 _◆_

_◆_ : ∀ {j₁ j₂ j₃ t₁ t₂ t₃ ℓ₁ ℓ₂ ℓ₃}
        {J₁    : Set j₁}
        {J₂    : Set j₂}
        {J₃    : Set j₃}
        {Type₁ : Set ℓ₁}
        {Type₂ : Set ℓ₂}
        {Type₃ : Set ℓ₃}
        {Tm₁   : J₁ → Set t₁}
        {Tm₂   : J₂ → Set t₂}
        {Tm₃   : J₃ → Set t₃}
        → Translation Type₂ Type₃ Tm₂ Tm₃
        → Translation Type₁ Type₂ Tm₁ Tm₂
        → Translation Type₁ Type₃ Tm₁ Tm₃
f ◆ g = record
  { ⟦_⟧ᵗ = Translation.⟦ f ⟧ᵗ ∘ Translation.⟦ g ⟧ᵗ
  ; ⟦_⟧ʲ = Translation.⟦ f ⟧ʲ ∘ Translation.⟦ g ⟧ʲ
  ; [_]  = Translation.[ f ]  ∘ Translation.[ g ] }
