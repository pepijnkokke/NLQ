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


open import Function                              using (id; flip; _∘_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; subst)


module Logic.Classical.Ordered.LambekGrishin.ResMon.Origin {ℓ} (Atom : Set ℓ) where


open import Logic.Polarity
open import Logic.Classical.Ordered.LambekGrishin.Type                               Atom as T
open import Logic.Classical.Ordered.LambekGrishin.Type.Context.Polarised             Atom as TC
open import Logic.Classical.Ordered.LambekGrishin.ResMon.Judgement                   Atom
open import Logic.Classical.Ordered.LambekGrishin.ResMon.Judgement.Context.Polarised Atom as JC
open import Logic.Classical.Ordered.LambekGrishin.ResMon.Base                        Atom as LGB


module el where

  data Origin {B} ( J : Contextᴶ + ) (f : LG J [ el B ]ᴶ) : Set ℓ where
       origin : (f′ : ∀ {G} → LG G ⊢ el B → LG J [ G ]ᴶ)
              → (pr : f ≡ f′ ax)
              → Origin J f


  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ + ) (f : LG J [ el B ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       ax        = origin id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B}
         → ( I : Contextᴶ + ) (f : LG I [ el B ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin f′ pr rewrite pr = origin (g ∘ f′) refl



module □ where

  data Origin {B} ( J : Contextᴶ + ) (f : LG J [ □ B ]ᴶ) : Set ℓ where
       origin : ∀ {A}
                → (h : LG B ⊢ A)
                → (f′ : ∀ {G} → LG G ⊢ □ A → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m□ h))
                → Origin J f

  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ + ) (f : LG J [ □ B ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       (m□  f)   = origin f id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B}
         → ( I : Contextᴶ + ) (f : LG I [ □ B ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h f′ pr rewrite pr = origin h (g ∘ f′) refl



module ₀ where

  data Origin {B} ( J : Contextᴶ + ) (f : LG J [ ₀ B ]ᴶ) : Set ℓ where
       origin : ∀ {A}
              → (h  : LG A ⊢ B)
              → (f′ : ∀ {G} → LG G ⊢ ₀ A → LG J [ G ]ᴶ)
              → (pr : f ≡ f′ (m₀ h))
              → Origin J f

  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ + ) (f : LG J [ ₀ B ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       (m₀  f)   = origin f id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B}
         → ( I : Contextᴶ + ) (f : LG I [ ₀ B ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h f′ pr rewrite pr = origin h (g ∘ f′) refl



module ⁰ where

  data Origin {B} ( J : Contextᴶ + ) (f : LG J [ B ⁰ ]ᴶ) : Set ℓ where
       origin : ∀ {A}
              → (h  : LG A ⊢ B)
              → (f′ : ∀ {G} → LG G ⊢ A ⁰ → LG J [ G ]ᴶ)
              → (pr : f ≡ f′ (m⁰ h))
              → Origin J f

--viewOrigin : ∀ {B} ( J : Contextᴶ + ) (f : LG J [ B ⁰ ]ᴶ) → Origin J f
--viewOrigin {B} J f = o⋈⋈
--  where
--    f⋈ : LG (J ⋈ᴶ′) [ ₀ (B ⋈) ]ᴶ
--    f⋈ rewrite sym (⋈ᴶ-over-[]ᴶ J {B ⁰}) = lemma-⋈ f
--    o⋈⋈ : Origin J f
--    o⋈⋈ with ₀.viewOrigin (J ⋈ᴶ′) f⋈
--    o⋈⋈ | ₀.origin {A} h f′ pr = origin h⋈ f′⋈ {!pr!}
--      where
--        h⋈ : LG A ⋈ ⊢ B
--        h⋈ = subst (λ B → LG A ⋈ ⊢ B) (⋈-inv B) (lemma-⋈ h)
--        f′⋈ : ∀ {G} → LG G ⊢ (A ⋈) ⁰ → LG J [ G ]ᴶ
--        f′⋈ {G} x = subst LG_ (⋈ᴶ-inv (J [ G ]ᴶ)) (lemma-⋈ [f′x]⋈)
--          where
--            x⋈ : LG G ⋈ ⊢ ₀ A
--            x⋈ = subst (λ A → LG G ⋈ ⊢ ₀ A) (⋈-inv A) (lemma-⋈ x)
--            [f′x]⋈ : LG (J [ G ]ᴶ) ⋈ᴶ
--            [f′x]⋈ = subst LG_ (sym (⋈ᴶ-over-[]ᴶ J {G})) (f′ x⋈)
  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ + ) (f : LG J [ B ⁰ ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       (m⁰  f)   = origin f id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹


    private
      go : ∀ {B}
         → ( I : Contextᴶ + ) (f : LG I [ B ⁰ ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h f′ pr rewrite pr = origin h (g ∘ f′) refl



module ⊕ where

  data Origin {B C} ( J : Contextᴶ + ) (f : LG J [ B ⊕ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG C ⊢ F)
                → (f′ : ∀ {G} → LG G ⊢ E ⊕ F → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⊕ h₁ h₂))
                → Origin J f

  mutual
    viewOrigin : ∀ {B C} ( J : Contextᴶ + ) (f : LG J [ B ⊕ C ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       (m⊕  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B C}
         → ( I : Contextᴶ + ) (f : LG I [ B ⊕ C ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl



module ⇐ where

  data Origin {B C} ( J : Contextᴶ + ) (f : LG J [ B ⇐ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG G ⊢ E ⇐ F → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⇐ h₁ h₂))
                → Origin J f

  mutual
    viewOrigin : ∀ {B C} ( J : Contextᴶ + ) (f : LG J [ B ⇐ C ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       (m⇐  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B C}
         → ( I : Contextᴶ + ) (f : LG I [ B ⇐ C ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl



module ⇒ where

  data Origin {B C} ( J : Contextᴶ + ) (f : LG J [ B ⇒ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG E ⊢ B) (h₂ : LG C ⊢ F)
                → (f′ : ∀ {G} → LG G ⊢ E ⇒ F → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⇒ h₁ h₂))
                → Origin J f

  mutual
    viewOrigin : ∀ {B C} ( J : Contextᴶ + ) (f : LG J [ B ⇒ C ]ᴶ) → Origin J f
    viewOrigin ([] <⊢ ._)       (m⇒  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin ([] <⊢ ._)       (r⊗⇒ f)   = go ((_ ⊗> []) <⊢ _)       f r⊗⇒
    viewOrigin ([] <⊢ ._)       (r⊗⇐ f)   = go (([] <⊗ _) <⊢ _)       f r⊗⇐
    viewOrigin ([] <⊢ ._)       (r⇛⊕ f)   = go ((_ ⇛> []) <⊢ _)       f r⇛⊕
    viewOrigin ([] <⊢ ._)       (r⇚⊕ f)   = go (([] <⇚ _) <⊢ _)       f r⇚⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin ([] <⊢ ._)       (r◇□ f)   = go ((◇>   []) <⊢ _)       f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin ([] <⊢ ._)       (r⁰₀ f)   = go (_ ⊢> [] <⁰)           f r⁰₀
    viewOrigin ([] <⊢ ._)       (r₀⁰ f)   = go (_ ⊢> ₀> [])           f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B C}
         → ( I : Contextᴶ + ) (f : LG I [ B ⇒ C ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl



module ◇ where

  data Origin {B} ( J : Contextᴶ - ) (f : LG J [ ◇ B ]ᴶ) : Set ℓ where
       origin : ∀ {A}
                → (h : LG A ⊢ B)
                → (f′ : ∀ {G} → LG ◇ A ⊢ G → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m◇ h))
                → Origin J f

  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ - ) (f : LG J [ ◇ B ]ᴶ) → Origin J f
    viewOrigin (._ ⊢> [])       (m◇  f)   = origin f id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin (._ ⊢> [])       (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> []))       f r⇒⊗
    viewOrigin (._ ⊢> [])       (r⇐⊗ f)   = go (_ ⊢> ([] <⇐ _))       f r⇐⊗
    viewOrigin (._ ⊢> [])       (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> []))       f r⊕⇛
    viewOrigin (._ ⊢> [])       (r⊕⇚ f)   = go (_ ⊢> ([] <⊕ _))       f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin (._ ⊢> [])       (r□◇ f)   = go (_ ⊢> (□> []))         f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin (._ ⊢> [])       (r¹₁ f)   = go ([] <¹ <⊢ _)           f r¹₁
    viewOrigin (._ ⊢> [])       (r₁¹ f)   = go (₁> [] <⊢ _)           f r₁¹
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B}
         → ( I : Contextᴶ - ) (f : LG I [ ◇ B ]ᴶ)
         → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h f′ pr rewrite pr = origin h (g ∘ f′) refl



module ₁ where

  data Origin {B} ( J : Contextᴶ - ) (f : LG J [ ₁ B ]ᴶ) : Set ℓ where
       origin : ∀ {A}
                → (h : LG B ⊢ A)
                → (f′ : ∀ {G} → LG ₁ A ⊢ G → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m₁ h))
                → Origin J f



  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ - ) (f : LG J [ ₁ B ]ᴶ) → Origin J f
    viewOrigin (._ ⊢> [])       (m₁  f)   = origin f id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin (._ ⊢> [])       (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> []))       f r⇒⊗
    viewOrigin (._ ⊢> [])       (r⇐⊗ f)   = go (_ ⊢> ([] <⇐ _))       f r⇐⊗
    viewOrigin (._ ⊢> [])       (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> []))       f r⊕⇛
    viewOrigin (._ ⊢> [])       (r⊕⇚ f)   = go (_ ⊢> ([] <⊕ _))       f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin (._ ⊢> [])       (r□◇ f)   = go (_ ⊢> (□> []))         f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin (._ ⊢> [])       (r¹₁ f)   = go ([] <¹ <⊢ _)           f r¹₁
    viewOrigin (._ ⊢> [])       (r₁¹ f)   = go (₁> [] <⊢ _)           f r₁¹
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B}
         → ( I : Contextᴶ - ) (f : LG I [ ₁ B ]ᴶ)
         → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h f′ pr rewrite pr = origin h (g ∘ f′) refl



module ¹ where

  data Origin {B} ( J : Contextᴶ - ) (f : LG J [ B ¹ ]ᴶ) : Set ℓ where
       origin : ∀ {A}
                → (h : LG B ⊢ A)
                → (f′ : ∀ {G} → LG A ¹ ⊢ G → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m¹ h))
                → Origin J f



  mutual
    viewOrigin : ∀ {B} ( J : Contextᴶ - ) (f : LG J [ B ¹ ]ᴶ) → Origin J f
    viewOrigin (._ ⊢> [])       (m¹  f)   = origin f id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin (._ ⊢> [])       (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> []))       f r⇒⊗
    viewOrigin (._ ⊢> [])       (r⇐⊗ f)   = go (_ ⊢> ([] <⇐ _))       f r⇐⊗
    viewOrigin (._ ⊢> [])       (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> []))       f r⊕⇛
    viewOrigin (._ ⊢> [])       (r⊕⇚ f)   = go (_ ⊢> ([] <⊕ _))       f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin (._ ⊢> [])       (r□◇ f)   = go (_ ⊢> (□> []))         f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin (._ ⊢> [])       (r¹₁ f)   = go ([] <¹ <⊢ _)           f r¹₁
    viewOrigin (._ ⊢> [])       (r₁¹ f)   = go (₁> [] <⊢ _)           f r₁¹
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B}
         → ( I : Contextᴶ - ) (f : LG I [ B ¹ ]ᴶ)
         → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h f′ pr rewrite pr = origin h (g ∘ f′) refl


module ⊗ where

  data Origin {B C} ( J : Contextᴶ - ) (f : LG J [ B ⊗ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG E ⊢ B) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG E ⊗ F ⊢ G → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⊗ h₁ h₂))
                → Origin J f

  mutual
    viewOrigin : ∀ {B C} ( J : Contextᴶ - ) (f : LG J [ B ⊗ C ]ᴶ) → Origin J f
    viewOrigin (._ ⊢> [])       (m⊗  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin (._ ⊢> [])       (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> []))       f r⇒⊗
    viewOrigin (._ ⊢> [])       (r⇐⊗ f)   = go (_ ⊢> ([] <⇐ _))       f r⇐⊗
    viewOrigin (._ ⊢> [])       (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> []))       f r⊕⇛
    viewOrigin (._ ⊢> [])       (r⊕⇚ f)   = go (_ ⊢> ([] <⊕ _))       f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin (._ ⊢> [])       (r□◇ f)   = go (_ ⊢> (□> []))         f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin (._ ⊢> [])       (r¹₁ f)   = go ([] <¹ <⊢ _)           f r¹₁
    viewOrigin (._ ⊢> [])       (r₁¹ f)   = go (₁> [] <⊢ _)           f r₁¹
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B C}
         → ( I : Contextᴶ - ) (f : LG I [ B ⊗ C ]ᴶ)
         → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl




module ⇚ where

  data Origin {B C} ( J : Contextᴶ - ) (f : LG J [ B ⇚ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG E ⊢ B) (h₂ : LG C ⊢ F)
                → (f′ : ∀ {G} → LG E ⇚ F ⊢ G → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⇚ h₁ h₂))
                → Origin J f

  mutual
    viewOrigin : ∀ {B C} ( J : Contextᴶ - ) (f : LG J [ B ⇚ C ]ᴶ) → Origin J f
    viewOrigin (._ ⊢> [])       (m⇚  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin (._ ⊢> [])       (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> []))       f r⇒⊗
    viewOrigin (._ ⊢> [])       (r⇐⊗ f)   = go (_ ⊢> ([] <⇐ _))       f r⇐⊗
    viewOrigin (._ ⊢> [])       (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> []))       f r⊕⇛
    viewOrigin (._ ⊢> [])       (r⊕⇚ f)   = go (_ ⊢> ([] <⊕ _))       f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin (._ ⊢> [])       (r□◇ f)   = go (_ ⊢> (□> []))         f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin (._ ⊢> [])       (r¹₁ f)   = go ([] <¹ <⊢ _)           f r¹₁
    viewOrigin (._ ⊢> [])       (r₁¹ f)   = go (₁> [] <⊢ _)           f r₁¹
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B C}
         → ( I : Contextᴶ - ) (f : LG I [ B ⇚ C ]ᴶ)
         → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl



module ⇛ where

  data Origin {B C} ( J : Contextᴶ - ) (f : LG J [ B ⇛ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG E ⇛ F ⊢ G → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⇛ h₁ h₂))
                → Origin J f

  mutual
    viewOrigin : ∀ {B C} ( J : Contextᴶ - ) (f : LG J [ B ⇛ C ]ᴶ) → Origin J f
    viewOrigin (._ ⊢> [])       (m⇛  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    viewOrigin (._ ⊢> [])       (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> []))       f r⇒⊗
    viewOrigin (._ ⊢> [])       (r⇐⊗ f)   = go (_ ⊢> ([] <⇐ _))       f r⇐⊗
    viewOrigin (._ ⊢> [])       (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> []))       f r⊕⇛
    viewOrigin (._ ⊢> [])       (r⊕⇚ f)   = go (_ ⊢> ([] <⊕ _))       f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⊗> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    viewOrigin ((A ⊗> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⊗> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⊗> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⊗> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⊗> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇛> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇛> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇛> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    viewOrigin ((A ⇛> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇛> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    viewOrigin ((A ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A ⇚> B)) <⊢ _) f r⊗⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊗⇐ f)   = go (((A ⇚> B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A ⇚> B)) <⊢ _) f r⇛⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    viewOrigin ((A ⇚> B) <⊢ ._) (r⇚⊕ f)   = go (((A ⇚> B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    viewOrigin ((A ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⊗ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    viewOrigin ((A <⊗ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⊗ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⊗ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⊗ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⊗ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇛ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇛ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇛ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    viewOrigin ((A <⇛ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇛ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    viewOrigin ((A <⇛ B) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇒ f)   = go ((_ ⊗> (A <⇚ B)) <⊢ _) f r⊗⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊗⇐ f)   = go (((A <⇚ B) <⊗ _) <⊢ _) f r⊗⇐
    viewOrigin ((A <⇚ B) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇛⊕ f)   = go ((_ ⇛> (A <⇚ B)) <⊢ _) f r⇛⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    viewOrigin ((A <⇚ B) <⊢ ._) (r⇚⊕ f)   = go (((A <⇚ B) <⇚ _) <⊢ _) f r⇚⊕
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    viewOrigin ((A <⇚ B) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⊕> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⊕> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⊕> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⊕> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⊕> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    viewOrigin (._ ⊢> (A ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇒> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇒> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇒> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇒> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇒> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    viewOrigin (._ ⊢> (A ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    viewOrigin (._ ⊢> (A ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A ⇐> B))) f r⇒⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⇐⊗ f)   = go (_ ⊢> ((A ⇐> B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A ⇐> B))) f r⊕⇛
    viewOrigin (._ ⊢> (A ⇐> B)) (r⊕⇚ f)   = go (_ ⊢> ((A ⇐> B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    viewOrigin (._ ⊢> (A ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⊕ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⊕ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⊕ B)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⊕ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⊕ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⊕ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⊕ B)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    viewOrigin (._ ⊢> (A <⇒ B)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇒ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇒ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇒ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇒ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇒ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    viewOrigin (._ ⊢> (A <⇒ B)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    viewOrigin (._ ⊢> (A <⇐ B)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (A <⇐ B))) f r⇒⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⇐⊗ f)   = go (_ ⊢> ((A <⇐ B) <⇐ _)) f r⇐⊗
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (A <⇐ B))) f r⊕⇛
    viewOrigin (._ ⊢> (A <⇐ B)) (r⊕⇚ f)   = go (_ ⊢> ((A <⇐ B) <⊕ _)) f r⊕⇚
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    viewOrigin (._ ⊢> (A <⇐ B)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    viewOrigin (._ ⊢> [])       (r□◇ f)   = go (_ ⊢> (□> []))         f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    viewOrigin ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    viewOrigin ((◇> A) <⊢ ._)   (r◇□ f)   = go ((◇> (◇> A)) <⊢ _)     f r◇□
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇒ f)   = go ((_ ⊗> (◇> A)) <⊢ _)   f r⊗⇒
    viewOrigin ((◇> A) <⊢ ._)   (r⊗⇐ f)   = go (((◇> A) <⊗ _) <⊢ _)   f r⊗⇐
    viewOrigin ((◇> A) <⊢ ._)   (r⇛⊕ f)   = go ((_ ⇛> (◇> A)) <⊢ _)   f r⇛⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⇚⊕ f)   = go (((◇> A) <⇚ _) <⊢ _)   f r⇚⊕
    viewOrigin (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    viewOrigin (._ ⊢> (□> B))   (r□◇ f)   = go (_ ⊢> (□> (□> B)))     f r□◇
    viewOrigin (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□
    viewOrigin (._ ⊢> (□> B))   (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> (□> B)))   f r⇒⊗
    viewOrigin (._ ⊢> (□> B))   (r⇐⊗ f)   = go (_ ⊢> ((□> B) <⇐ _))   f r⇐⊗
    viewOrigin (._ ⊢> (□> B))   (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> (□> B)))   f r⊕⇛
    viewOrigin (._ ⊢> (□> B))   (r⊕⇚ f)   = go (_ ⊢> ((□> B) <⊕ _))   f r⊕⇚
    viewOrigin (._ ⊢> (A ⊕> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⊕> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇒> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇒> B)))   f r□◇
    viewOrigin (._ ⊢> (A ⇐> B)) (r□◇ f)   = go (_ ⊢> (□> (A ⇐> B)))   f r□◇
    viewOrigin (._ ⊢> (A <⊕ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⊕ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇒ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇒ B)))   f r□◇
    viewOrigin (._ ⊢> (A <⇐ B)) (r□◇ f)   = go (_ ⊢> (□> (A <⇐ B)))   f r□◇
    viewOrigin ((A ⊗> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⊗> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇛> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇛> B)) <⊢ _)   f r◇□
    viewOrigin ((A ⇚> B) <⊢ ._) (r◇□ f)   = go ((◇> (A ⇚> B)) <⊢ _)   f r◇□
    viewOrigin ((A <⊗ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⊗ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇛ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇛ B)) <⊢ _)   f r◇□
    viewOrigin ((A <⇚ B) <⊢ ._) (r◇□ f)   = go ((◇> (A <⇚ B)) <⊢ _)   f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    viewOrigin (._ ⊢> [])       (r¹₁ f)   = go ([] <¹ <⊢ _)           f r¹₁
    viewOrigin (._ ⊢> [])       (r₁¹ f)   = go (₁> [] <⊢ _)           f r₁¹
    viewOrigin ((₁> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (₁> A) <⁰)       f r⁰₀
    viewOrigin ((₁> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (₁> A))       f r₀⁰
    viewOrigin ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    viewOrigin ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁
    viewOrigin ((₁> A) <⊢ ._)   (r◇□ f)   = go (◇> (₁> A) <⊢ _)       f r◇□
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (₁> A) <⊢ _)     f r⊗⇒
    viewOrigin ((₁> A) <⊢ ._)   (r⊗⇐ f)   = go ((₁> A) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((₁> A) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (₁> A) <⊢ _)     f r⇛⊕
    viewOrigin ((₁> A) <⊢ ._)   (r⇚⊕ f)   = go ((₁> A) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((A <¹) <⊢ ._)   (r◇□ f)   = go (◇> (A <¹) <⊢ _)       f r◇□
    viewOrigin ((A <¹) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> (A <¹) <⁰)       f r⁰₀
    viewOrigin ((A <¹) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> ₀> (A <¹))       f r₀⁰
    viewOrigin ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    viewOrigin ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇒ f)   = go (_ ⊗> (A <¹) <⊢ _)     f r⊗⇒
    viewOrigin ((A <¹) <⊢ ._)   (r⊗⇐ f)   = go ((A <¹) <⊗ _ <⊢ _)     f r⊗⇐
    viewOrigin ((A <¹) <⊢ ._)   (r⇛⊕ f)   = go (_ ⇛> (A <¹) <⊢ _)     f r⇛⊕
    viewOrigin ((A <¹) <⊢ ._)   (r⇚⊕ f)   = go ((A <¹) <⇚ _ <⊢ _)     f r⇚⊕
    viewOrigin ((◇> A) <⊢ ._)   (r⁰₀ f)   = go (_ ⊢> ((◇> A) <⁰))     f r⁰₀
    viewOrigin ((◇> A) <⊢ ._)   (r₀⁰ f)   = go (_ ⊢> (₀> (◇> A)))     f r₀⁰
    viewOrigin (._ ⊢> (□> B))   (r¹₁ f)   = go ((□> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (□> B))   (r₁¹ f)   = go (₁> (□> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r□◇ f)   = go (_ ⊢> □> (₀> B))       f r□◇
    viewOrigin (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    viewOrigin (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    viewOrigin (._ ⊢> (₀> B))   (r¹₁ f)   = go ((₀> B) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (₀> B))   (r₁¹ f)   = go (₁> (₀> B) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (₀> B))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (₀> B))     f r⇒⊗
    viewOrigin (._ ⊢> (₀> B))   (r⇐⊗ f)   = go (_ ⊢> (₀> B) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (₀> B))     f r⊕⇛
    viewOrigin (._ ⊢> (₀> B))   (r⊕⇚ f)   = go (_ ⊢> (₀> B) <⊕ _)     f r⊕⇚
    viewOrigin (._ ⊢> (B <⁰))   (r□◇ f)   = go (_ ⊢> □> (B <⁰))       f r□◇
    viewOrigin (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    viewOrigin (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    viewOrigin (._ ⊢> (B <⁰))   (r¹₁ f)   = go ((B <⁰) <¹ <⊢ _)       f r¹₁
    viewOrigin (._ ⊢> (B <⁰))   (r₁¹ f)   = go (₁> (B <⁰) <⊢ _)       f r₁¹
    viewOrigin (._ ⊢> (B <⁰))   (r⇒⊗ f)   = go (_ ⊢> _ ⇒> (B <⁰))     f r⇒⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⇐⊗ f)   = go (_ ⊢> (B <⁰) <⇐ _)     f r⇐⊗
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇛ f)   = go (_ ⊢> _ ⊕> (B <⁰))     f r⊕⇛
    viewOrigin (._ ⊢> (B <⁰))   (r⊕⇚ f)   = go (_ ⊢> (B <⁰) <⊕ _)     f r⊕⇚
    viewOrigin ((A ⊗> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⊗> B) <⁰)     f r⁰₀
    viewOrigin ((A ⊗> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⊗> B))     f r₀⁰
    viewOrigin ((A ⇛> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇛> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇛> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇛> B))     f r₀⁰
    viewOrigin ((A ⇚> B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A ⇚> B) <⁰)     f r⁰₀
    viewOrigin ((A ⇚> B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A ⇚> B))     f r₀⁰
    viewOrigin ((A <⊗ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⊗ B) <⁰)     f r⁰₀
    viewOrigin ((A <⊗ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⊗ B))     f r₀⁰
    viewOrigin ((A <⇛ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇛ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇛ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇛ B))     f r₀⁰
    viewOrigin ((A <⇚ B) <⊢ ._) (r⁰₀ f)   = go (_ ⊢> (A <⇚ B) <⁰)     f r⁰₀
    viewOrigin ((A <⇚ B) <⊢ ._) (r₀⁰ f)   = go (_ ⊢> ₀> (A <⇚ B))     f r₀⁰
    viewOrigin (._ ⊢> (A ⊕> B)) (r¹₁ f)   = go ((A ⊕> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⊕> B)) (r₁¹ f)   = go (₁> (A ⊕> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇒> B)) (r¹₁ f)   = go ((A ⇒> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇒> B)) (r₁¹ f)   = go (₁> (A ⇒> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A ⇐> B)) (r¹₁ f)   = go ((A ⇐> B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A ⇐> B)) (r₁¹ f)   = go (₁> (A ⇐> B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⊕ B)) (r¹₁ f)   = go ((A <⊕ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⊕ B)) (r₁¹ f)   = go (₁> (A <⊕ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇒ B)) (r¹₁ f)   = go ((A <⇒ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇒ B)) (r₁¹ f)   = go (₁> (A <⇒ B) <⊢ _)     f r₁¹
    viewOrigin (._ ⊢> (A <⇐ B)) (r¹₁ f)   = go ((A <⇐ B) <¹ <⊢ _)     f r¹₁
    viewOrigin (._ ⊢> (A <⇐ B)) (r₁¹ f)   = go (₁> (A <⇐ B) <⊢ _)     f r₁¹

    private
      go : ∀ {B C}
         → ( I : Contextᴶ - ) (f : LG I [ B ⇛ C ]ᴶ)
         → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with viewOrigin I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl
