------------------------------------------------------------------------
-- The Lambek Calculus in Agda
------------------------------------------------------------------------


module Logic.Intuitionistic.Ordered.InSitu.Type.Context.Polarised {ℓ} (Atom : Set ℓ) where


open import Logic.Polarity
open import Logic.Intuitionistic.Ordered.InSitu.Type Atom


infixr 20 _⊗>_ _∘>_
infixr 30 _⇒>_ _⇨>_ _⇐>_ _⇦>_
infixl 20 _<⊗_ _<∘_
infixl 30 _<⇒_ _<⇨_ _<⇐_ _<⇦_
infixr 40 ◇>_ □>_
infixl 50 _[_]


data Context : Polarity → Set ℓ where

  []   : ∀ {p} → Context p

  ◇>_  : Context + → Context +
  □>_  : Context - → Context -

  _⊗>_ : Type → Context + → Context +
  _⇒>_ : Type → Context - → Context -
  _⇐>_ : Type → Context + → Context -
  _∘>_ : Type → Context + → Context +
  _⇨>_ : Type → Context - → Context -
  _⇦>_ : Type → Context + → Context -

  _<⊗_ : Context + → Type → Context +
  _<⇒_ : Context + → Type → Context -
  _<⇐_ : Context - → Type → Context -
  _<∘_ : Context + → Type → Context +
  _<⇨_ : Context + → Type → Context -
  _<⇦_ : Context - → Type → Context -


_[_] : ∀ {p} → Context p → Type → Type
[]       [ A ] = A
(◇>   Σ) [ A ] = ◇ (Σ [ A ])
(□>   Σ) [ A ] = □ (Σ [ A ])
(B ⊗> Σ) [ A ] = B ⊗ (Σ [ A ])
(B ⇒> Σ) [ A ] = B ⇒ (Σ [ A ])
(B ⇐> Σ) [ A ] = B ⇐ (Σ [ A ])
(B ∘> Σ) [ A ] = B ∘ (Σ [ A ])
(B ⇨> Σ) [ A ] = B ⇨ (Σ [ A ])
(B ⇦> Σ) [ A ] = B ⇦ (Σ [ A ])
(Σ <⊗ B) [ A ] = (Σ [ A ]) ⊗ B
(Σ <⇒ B) [ A ] = (Σ [ A ]) ⇒ B
(Σ <⇐ B) [ A ] = (Σ [ A ]) ⇐ B
(Σ <∘ B) [ A ] = (Σ [ A ]) ∘ B
(Σ <⇨ B) [ A ] = (Σ [ A ]) ⇨ B
(Σ <⇦ B) [ A ] = (Σ [ A ]) ⇦ B
