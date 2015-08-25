------------------------------------------------------------------------
-- The Lambek Calculus in Agda
------------------------------------------------------------------------


open import Function                              using (id; flip; _∘_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; subst)


module Logic.LG.ResMon.Origin.ImpL {ℓ} (Atom : Set ℓ) where


  open import Logic.Polarity
  open import Logic.LG.Type                               Atom as T
  open import Logic.LG.Type.Context.Polarised             Atom as TC
  open import Logic.LG.ResMon.Judgement                   Atom
  open import Logic.LG.ResMon.Judgement.Context.Polarised Atom as JC
  open import Logic.LG.ResMon.Base                        Atom as LGB


  data Origin {B C} ( J : Contextᴶ + ) (f : LG J [ B ⇐ C ]ᴶ) : Set ℓ where
       origin : ∀ {E F}
                → (h₁ : LG B ⊢ E) (h₂ : LG F ⊢ C)
                → (f′ : ∀ {G} → LG G ⊢ E ⇐ F → LG J [ G ]ᴶ)
                → (pr : f ≡ f′ (m⇐ h₁ h₂))
                → Origin J f

  mutual
    view : ∀ {B C} ( J : Contextᴶ + ) (f : LG J [ B ⇐ C ]ᴶ) → Origin J f
    view ([] <⊢ ._)       (m⇐  f g) = origin f g id refl

    -- cases for (⇐ , ⊗ , ⇒) and (⇚ , ⊕ , ⇛)
    view ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
    view ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
    view (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
    view (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
    view (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
    view (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
    view (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
    view (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
    view (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
    view ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
    view ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
    view (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
    view (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
    view (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
    view (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
    view ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
    view ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
    view (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
    view ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
    view ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
    view ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
    view ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
    view (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
    view (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
    view (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
    view (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
    view (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
    view ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
    view ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
    view (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
    view (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
    view (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
    view (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
    view ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
    view ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
    view (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
    view ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
    view ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
    view (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
    view (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
    view ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
    view ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
    view (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
    view (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
    view ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
    view ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
    view (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
    view (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
    view ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
    view ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
    view (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
    view (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

    -- cases for (□ , ◇)
    view (._ ⊢> (□> B))   (m□  f)   = go (_ ⊢> B)               f m□
    view ((◇> A) <⊢ ._)   (m◇  f)   = go (A <⊢ _)               f m◇
    view (._ ⊢> B)        (r□◇ f)   = go (_ ⊢> (□> B))          f r□◇
    view ((◇> A) <⊢ ._)   (r□◇ f)   = go (A <⊢ _)               f r□◇
    view (A <⊢ ._)        (r◇□ f)   = go ((◇> A) <⊢ _)          f r◇□
    view (._ ⊢> (□> B))   (r◇□ f)   = go (_ ⊢> B)               f r◇□

    -- cases for (₀ , ⁰) and (₁ , ¹)
    view (._ ⊢> (₀> B))   (m₀  f)   = go (B <⊢ _)               f m₀
    view (._ ⊢> (B <⁰))   (m⁰  f)   = go (B <⊢ _)               f m⁰
    view (A <⊢ ._)        (r₀⁰ f)   = go (_ ⊢> ₀> A)            f r₀⁰
    view (._ ⊢> (B <⁰))   (r₀⁰ f)   = go (B <⊢ _)               f r₀⁰
    view (A <⊢ ._)        (r⁰₀ f)   = go (_ ⊢> A <⁰)            f r⁰₀
    view (._ ⊢> (₀> B))   (r⁰₀ f)   = go (B <⊢ _)               f r⁰₀
    view ((₁> A) <⊢ ._)   (m₁  f)   = go (_ ⊢> A)               f m₁
    view ((A <¹) <⊢ ._)   (m¹  f)   = go (_ ⊢> A)               f m¹
    view (._ ⊢> B)        (r₁¹ f)   = go (₁> B <⊢ _)            f r₁¹
    view ((A <¹) <⊢ ._)   (r₁¹ f)   = go (_ ⊢> A)               f r₁¹
    view (._ ⊢> B)        (r¹₁ f)   = go (B <¹ <⊢ _)            f r¹₁
    view ((₁> A) <⊢ ._)   (r¹₁ f)   = go (_ ⊢> A)               f r¹₁

    private
      go : ∀ {B C}
         → ( I : Contextᴶ + ) (f : LG I [ B ⇐ C ]ᴶ)
         → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
         → Origin J (g f)
      go I f {J} g with view I f
      ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl