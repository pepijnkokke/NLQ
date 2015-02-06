------------------------------------------------------------------------
-- The Lambek Calculus in Agda
--
-- Implements several views on proofs in the system ResMon which are
-- heavily used in the proof of admissibility of the transitivity rule.
--
-- One advantage of the residuation-monotonicity calculus is that
-- every connective *must* be introduced by an application of the
-- corresponding monotonicity-rule. The proofs in the `Origin` module
-- can be used to construct a view on a proof that makes this
-- introducing application of a monotonicity-rule explicit.
--
-- The proofs in this module are highly repetitive, and the decision
-- procedures and data structures could be abstracted over by
-- generalising over the connectives (cutting the file length by ±750
-- lines). However, I feel that abstracting over connectives would
-- make the logic a lot harder to read. I may do it in the future
-- anyway.
------------------------------------------------------------------------


open import Relation.Binary.PropositionalEquality as P using (_≡_; refl; cong)


module Logic.Classical.Ordered.LambekGrishin.Origin {ℓ} (Univ : Set ℓ) where


open import Logic.Polarity
open import Logic.Classical.Ordered.LambekGrishin.Type                        Univ as T
open import Logic.Classical.Ordered.LambekGrishin.Type.Context                Univ as TC
open import Logic.Classical.Ordered.LambekGrishin.Type.Context.Polarised      Univ as TCP hiding (Polarised)
open import Logic.Classical.Ordered.LambekGrishin.Judgement                   Univ
open import Logic.Classical.Ordered.LambekGrishin.Judgement.Context           Univ as JC
open import Logic.Classical.Ordered.LambekGrishin.Judgement.Context.Polarised Univ as JCP
open import Logic.Classical.Ordered.LambekGrishin.Base                        Univ as LGB
open import Logic.Classical.Ordered.LambekGrishin.Derivation                  Univ as LGD


open  JC.Simple renaming (_[_] to _[_]ᴶ)
open LGD.Simple renaming (_[_] to _[_]ᴰ; _<_> to _<_>ᴰ; <>-def to <>ᴰ-def)


module el where

  data Origin {J B} (J⁺ : Polarised + J) (f : LG J [ el B ]ᴶ) : Set ℓ where
       origin : (f′ : ∀ {G} → LG G ⊢ el B ⋯ J [ G ]ᴶ)
              → (pr : f ≡ f′ [ id ]ᴰ)
              → Origin J⁺ f

  mutual
    viewOrigin : ∀ {J B} (J⁺ : Polarised + J) (f : LG J [ el B ]ᴶ) → Origin J⁺ f
    viewOrigin ([] <⊢ ._)       id             = origin [] refl
    viewOrigin ([] <⊢ ._)       (res-⊗⇒ f)     = go ((_ ⊗> []) <⊢ _)       f  (res-⊗⇒ [])
    viewOrigin ([] <⊢ ._)       (res-⊗⇐ f)     = go (([] <⊗ _) <⊢ _)       f  (res-⊗⇐ [])
    viewOrigin ([] <⊢ ._)       (res-⇛⊕ f)     = go ((_ ⇛> []) <⊢ _)       f  (res-⇛⊕ [])
    viewOrigin ([] <⊢ ._)       (res-⇚⊕ f)     = go (([] <⇚ _) <⊢ _)       f  (res-⇚⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])

    private
      go : ∀ {I J B}
                     → (I⁺ : Polarised + I) (f : LG I [ el B ]ᴶ)
                     → {J⁺ : Polarised + J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁺ (g [ f ]ᴰ)
      go I⁺ f {J⁺} g with viewOrigin I⁺ f
      ... | origin f′ pr = origin (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ id ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g id = cong (_[_]ᴰ g) pr



module ⊗ where

  data Origin {J B C} (J⁻ : Polarised - J) (f : LG J [ B ⊗ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG E ⊢ B) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG E ⊗ F ⊢ G ⋯ J [ G ]ᴶ)
                → (pr : f ≡ f′ [ mon-⊗ h₁ h₂ ]ᴰ)
                → Origin J⁻ f

  mutual
    viewOrigin : ∀ {J B C} (J⁻ : Polarised - J) (f : LG J [ B ⊗ C ]ᴶ) → Origin J⁻ f
    viewOrigin (._ ⊢> [])       (mon-⊗  f₁ f₂) = origin f₁ f₂ [] refl
    viewOrigin (._ ⊢> [])       (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> []))       f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> [])       (res-⇐⊗ f)     = go (_ ⊢> ([] <⇐ _))       f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> [])       (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> []))       f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> [])       (res-⊕⇚ f)     = go (_ ⊢> ([] <⊕ _))       f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])

    private
      go : ∀ {I J B C}
                     → (I⁻ : Polarised - I) (f : LG I [ B ⊗ C ]ᴶ)
                     → {J⁻ : Polarised - J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁻ (g [ f ]ᴰ)
      go I⁻ f {J⁻} g with viewOrigin I⁻ f
      ... | origin h₁ h₂ f′ pr = origin h₁ h₂ (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ mon-⊗ h₁ h₂ ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g (mon-⊗ h₁ h₂) = cong (_[_]ᴰ g) pr





module ⇚ where

  data Origin {J B C} (J⁻ : Polarised - J) (f : LG J [ B ⇚ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG E ⊢ B) (h₂ : LG C ⊢ F)
                → (f′ : ∀ {G} → LG E ⇚ F ⊢ G ⋯ J [ G ]ᴶ)
                → (pr : f ≡ f′ [ mon-⇚ h₁ h₂ ]ᴰ)
                → Origin J⁻ f

  mutual
    viewOrigin : ∀ {J B C} (J⁻ : Polarised - J) (f : LG J [ B ⇚ C ]ᴶ) → Origin J⁻ f
    viewOrigin (._ ⊢> [])       (mon-⇚  f₁ f₂) = origin f₁ f₂ [] refl
    viewOrigin (._ ⊢> [])       (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> []))       f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> [])       (res-⇐⊗ f)     = go (_ ⊢> ([] <⇐ _))       f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> [])       (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> []))       f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> [])       (res-⊕⇚ f)     = go (_ ⊢> ([] <⊕ _))       f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])

    private
      go : ∀ {I J B C}
                     → (I⁻ : Polarised - I) (f : LG I [ B ⇚ C ]ᴶ)
                     → {J⁻ : Polarised - J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁻ (g [ f ]ᴰ)
      go I⁻ f {J⁻} g with viewOrigin I⁻ f
      ... | origin h₁ h₂ f′ pr = origin h₁ h₂ (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ mon-⇚ h₁ h₂ ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g (mon-⇚ h₁ h₂) = cong (_[_]ᴰ g) pr





module ⇛ where

  data Origin {J B C} (J⁻ : Polarised - J) (f : LG J [ B ⇛ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG E ⇛ F ⊢ G ⋯ J [ G ]ᴶ)
                → (pr : f ≡ f′ [ mon-⇛ h₁ h₂ ]ᴰ)
                → Origin J⁻ f

  mutual
    viewOrigin : ∀ {J B C} (J⁻ : Polarised - J) (f : LG J [ B ⇛ C ]ᴶ) → Origin J⁻ f
    viewOrigin (._ ⊢> [])       (mon-⇛  f₁ f₂) = origin f₁ f₂ [] refl
    viewOrigin (._ ⊢> [])       (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> []))       f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> [])       (res-⇐⊗ f)     = go (_ ⊢> ([] <⇐ _))       f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> [])       (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> []))       f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> [])       (res-⊕⇚ f)     = go (_ ⊢> ([] <⊕ _))       f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])

    private
      go : ∀ {I J B C}
                     → (I⁻ : Polarised - I) (f : LG I [ B ⇛ C ]ᴶ)
                     → {J⁻ : Polarised - J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁻ (g [ f ]ᴰ)
      go I⁻ f {J⁻} g with viewOrigin I⁻ f
      ... | origin h₁ h₂ f′ pr = origin h₁ h₂ (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ mon-⇛ h₁ h₂ ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g (mon-⇛ h₁ h₂) = cong (_[_]ᴰ g) pr




module ⊕ where

  data Origin {J B C} (J⁺ : Polarised + J) (f : LG J [ B ⊕ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG C ⊢ F)
                → (f′ : ∀ {G} → LG G ⊢ E ⊕ F ⋯ J [ G ]ᴶ)
                → (pr : f ≡ f′ [ mon-⊕ h₁ h₂ ]ᴰ)
                → Origin J⁺ f

  mutual
    viewOrigin : ∀ {J B C} (J⁺ : Polarised + J) (f : LG J [ B ⊕ C ]ᴶ) → Origin J⁺ f
    viewOrigin ([] <⊢ ._)       (mon-⊕  f₁ f₂) = origin f₁ f₂ [] refl
    viewOrigin ([] <⊢ ._)       (res-⊗⇒ f)     = go ((_ ⊗> []) <⊢ _)       f  (res-⊗⇒ [])
    viewOrigin ([] <⊢ ._)       (res-⊗⇐ f)     = go (([] <⊗ _) <⊢ _)       f  (res-⊗⇐ [])
    viewOrigin ([] <⊢ ._)       (res-⇛⊕ f)     = go ((_ ⇛> []) <⊢ _)       f  (res-⇛⊕ [])
    viewOrigin ([] <⊢ ._)       (res-⇚⊕ f)     = go (([] <⇚ _) <⊢ _)       f  (res-⇚⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])

    private
      go : ∀ {I J B C}
                     → (I⁺ : Polarised + I) (f : LG I [ B ⊕ C ]ᴶ)
                     → {J⁺ : Polarised + J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁺ (g [ f ]ᴰ)
      go I⁺ f {J⁺} g with viewOrigin I⁺ f
      ... | origin h₁ h₂ f′ pr = origin h₁ h₂ (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ mon-⊕ h₁ h₂ ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g (mon-⊕ h₁ h₂) = cong (_[_]ᴰ g) pr




module ⇐ where

  data Origin {J B C} (J⁺ : Polarised + J) (f : LG J [ B ⇐ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG G ⊢ E ⇐ F ⋯ J [ G ]ᴶ)
                → (pr : f ≡ f′ [ mon-⇐ h₁ h₂ ]ᴰ)
                → Origin J⁺ f

  mutual
    viewOrigin : ∀ {J B C} (J⁺ : Polarised + J) (f : LG J [ B ⇐ C ]ᴶ) → Origin J⁺ f
    viewOrigin ([] <⊢ ._)       (mon-⇐  f₁ f₂) = origin f₁ f₂ [] refl
    viewOrigin ([] <⊢ ._)       (res-⊗⇒ f)     = go ((_ ⊗> []) <⊢ _)       f  (res-⊗⇒ [])
    viewOrigin ([] <⊢ ._)       (res-⊗⇐ f)     = go (([] <⊗ _) <⊢ _)       f  (res-⊗⇐ [])
    viewOrigin ([] <⊢ ._)       (res-⇛⊕ f)     = go ((_ ⇛> []) <⊢ _)       f  (res-⇛⊕ [])
    viewOrigin ([] <⊢ ._)       (res-⇚⊕ f)     = go (([] <⇚ _) <⊢ _)       f  (res-⇚⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])

    private
      go : ∀ {I J B C}
                     → (I⁺ : Polarised + I) (f : LG I [ B ⇐ C ]ᴶ)
                     → {J⁺ : Polarised + J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁺ (g [ f ]ᴰ)
      go I⁺ f {J⁺} g with viewOrigin I⁺ f
      ... | origin h₁ h₂ f′ pr = origin h₁ h₂ (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ mon-⇐ h₁ h₂ ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g (mon-⇐ h₁ h₂) = cong (_[_]ᴰ g) pr




module ⇒ where

  data Origin {J B C} (J⁺ : Polarised + J) (f : LG J [ B ⇒ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG E ⊢ B) (h₂ : LG C ⊢ F)
                → (f′ : ∀ {G} → LG G ⊢ E ⇒ F ⋯ J [ G ]ᴶ)
                → (pr : f ≡ f′ [ mon-⇒ h₁ h₂ ]ᴰ)
                → Origin J⁺ f

  mutual
    viewOrigin : ∀ {J B C} (J⁺ : Polarised + J) (f : LG J [ B ⇒ C ]ᴶ) → Origin J⁺ f
    viewOrigin ([] <⊢ ._)       (mon-⇒  f₁ f₂) = origin f₁ f₂ [] refl
    viewOrigin ([] <⊢ ._)       (res-⊗⇒ f)     = go ((_ ⊗> []) <⊢ _)       f  (res-⊗⇒ [])
    viewOrigin ([] <⊢ ._)       (res-⊗⇐ f)     = go (([] <⊗ _) <⊢ _)       f  (res-⊗⇐ [])
    viewOrigin ([] <⊢ ._)       (res-⇛⊕ f)     = go ((_ ⇛> []) <⊢ _)       f  (res-⇛⊕ [])
    viewOrigin ([] <⊢ ._)       (res-⇚⊕ f)     = go (([] <⇚ _) <⊢ _)       f  (res-⇚⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (mon-⊗  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⊗ᴿ f₁ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇒⊗ f)     = go (B <⊢ _)               f  (res-⇒⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⊗> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇐⊗ f)     = go (_ ⊢> (_ ⇐> B))        f  (res-⇐⊗ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⊗> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⊗> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⊗> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⊗> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇛> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇛> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (mon-⇛  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇛ᴿ f₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇛> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⊕⇛ f)     = go (B <⊢ _)               f  (res-⊕⇛ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇛> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₁ f)     = go ((B <⊗ _) <⊢ _)        f  (grish₁ [])
    viewOrigin ((A ⇛> B) <⊢ ._) (grish₂ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₂ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A ⇚> B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊗⇐ f)     = go (((A ⇚> B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (mon-⇚  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇚ᴿ f₁ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A ⇚> B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⊕⇚ f)     = go (_ ⊢> (_ ⊕> B))        f  (res-⊕⇚ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (res-⇚⊕ f)     = go (((A ⇚> B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₃ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₃ [])
    viewOrigin ((A ⇚> B) <⊢ ._) (grish₄ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₄ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (mon-⊗  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⊗ᴸ [] f₂)
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇒⊗ f)     = go (_ ⊢> (A <⇒ _))        f  (res-⇒⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⊗ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇐⊗ f)     = go (A <⊢ _)               f  (res-⇐⊗ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⊗ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⊗ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⊗ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⊗ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇛ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇛ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (mon-⇛  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇛ᴸ [] f₂)
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇛ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⊕⇛ f)     = go (_ ⊢> (A <⊕ _))        f  (res-⊕⇛ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇛ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₁ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₁ [])
    viewOrigin ((A <⇛ B) <⊢ ._) (grish₂ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₂ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇒ f)     = go ((_ ⊗> (A <⇚ B)) <⊢ _) f  (res-⊗⇒ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊗⇐ f)     = go (((A <⇚ B) <⊗ _) <⊢ _) f  (res-⊗⇐ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (mon-⇚  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇚ᴸ [] f₂)
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇛⊕ f)     = go ((_ ⇛> (A <⇚ B)) <⊢ _) f  (res-⇛⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⊕⇚ f)     = go (A <⊢ _)               f  (res-⊕⇚ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (res-⇚⊕ f)     = go (((A <⇚ B) <⇚ _) <⊢ _) f  (res-⇚⊕ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₃ f)     = go ((_ ⊗> A) <⊢ _)        f  (grish₃ [])
    viewOrigin ((A <⇚ B) <⊢ ._) (grish₄ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⊕> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⊕> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (mon-⊕  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⊕ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇛⊕ f)     = go (_ ⊢> B)               f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⊕> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⊕> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⊕> B)) (res-⇚⊕ f)     = go ((_ ⇚> B) <⊢ _)        f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (mon-⇒  f₁ f₂) = go (_ ⊢> B)               f₂ (mon-⇒ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇒> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊗⇒ f)     = go (_ ⊢> B)               f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇒> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇒> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇒> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₂ f)     = go (_ ⊢> (_ ⊕> B))        f  (grish₂ [])
    viewOrigin (._ ⊢> (A ⇒> B)) (grish₃ f)     = go (_ ⊢> (B <⊕ _))        f  (grish₃ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (mon-⇐  f₁ f₂) = go (B <⊢ _)               f₂ (mon-⇐ᴿ f₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A ⇐> B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⇐⊗ f)     = go (_ ⊢> ((A ⇐> B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊗⇐ f)     = go ((_ ⊗> B) <⊢ _)        f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A ⇐> B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (res-⊕⇚ f)     = go (_ ⊢> ((A ⇐> B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₁ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₁ [])
    viewOrigin (._ ⊢> (A ⇐> B)) (grish₄ f)     = go ((_ ⊗> B) <⊢ _)        f  (grish₄ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⊕ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⊕ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (mon-⊕  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⊕ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇛⊕ f)     = go ((A <⇛ _) <⊢ _)        f  (res-⇛⊕ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⊕ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⊕ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⊕ B)) (res-⇚⊕ f)     = go (_ ⊢> A)               f  (res-⇚⊕ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (mon-⇒  f₁ f₂) = go (A <⊢ _)               f₁ (mon-⇒ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇒ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊗⇒ f)     = go ((A <⊗ _) <⊢ _)        f  (res-⊗⇒ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇒ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇒ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇒ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₂ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₂ [])
    viewOrigin (._ ⊢> (A <⇒ B)) (grish₃ f)     = go ((A <⊗ _) <⊢ _)        f  (grish₃ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (mon-⇐  f₁ f₂) = go (_ ⊢> A)               f₁ (mon-⇐ᴸ [] f₂)
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇒⊗ f)     = go (_ ⊢> (_ ⇒> (A <⇐ B))) f  (res-⇒⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⇐⊗ f)     = go (_ ⊢> ((A <⇐ B) <⇐ _)) f  (res-⇐⊗ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊗⇐ f)     = go (_ ⊢> A)               f  (res-⊗⇐ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇛ f)     = go (_ ⊢> (_ ⊕> (A <⇐ B))) f  (res-⊕⇛ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (res-⊕⇚ f)     = go (_ ⊢> ((A <⇐ B) <⊕ _)) f  (res-⊕⇚ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₁ f)     = go (_ ⊢> (_ ⊕> A))        f  (grish₁ [])
    viewOrigin (._ ⊢> (A <⇐ B)) (grish₄ f)     = go (_ ⊢> (A <⊕ _))        f  (grish₄ [])

    private
      go : ∀ {I J B C}
                     → (I⁺ : Polarised + I) (f : LG I [ B ⇒ C ]ᴶ)
                     → {J⁺ : Polarised + J} (g : ∀ {G} → LG I [ G ]ᴶ ⋯ J [ G ]ᴶ)
                     → Origin J⁺ (g [ f ]ᴰ)
      go I⁺ f {J⁺} g with viewOrigin I⁺ f
      ... | origin h₁ h₂ f′ pr = origin h₁ h₂ (g < f′ >ᴰ) pr′
        where
          pr′ : g [ f ]ᴰ ≡ (g < f′ >ᴰ) [ mon-⇒ h₁ h₂ ]ᴰ
          pr′ rewrite <>ᴰ-def f′ g (mon-⇒ h₁ h₂) = cong (_[_]ᴰ g) pr
