\documentclass[a4paper]{article}
\usepackage{stmaryrd}
\usepackage{comment}
\usepackage{etoolbox}
\usepackage{multicol}
\usepackage{catchfilebetweentags}
\usepackage{appendix}
\usepackage{hyperref}
\usepackage[links]{agda}
\setlength{\mathindent}{0cm}

%%% TODO UPDATE NUMBER MANUALLY -- SIGH
\setcounter{page}{59}

\def\lamET{\lambda^{\rightarrow}_{\{\mathbf{e},\mathbf{t}\}}}%
\DeclareUnicodeCharacter{738}{$^s$}
\DeclareUnicodeCharacter{7487}{$^R$}
\DeclareUnicodeCharacter{8852}{$\sqcup$}
\DeclareUnicodeCharacter{8704}{$\forall$}
\DeclareUnicodeCharacter{8866}{$\vdash$}
\DeclareUnicodeCharacter{8656}{$\mathbin{\slash}$}
\DeclareUnicodeCharacter{8658}{$\mathbin{\backslash}$}
\DeclareUnicodeCharacter{8729}{$\bullet$}
\DeclareUnicodeCharacter{8728}{$\circ$}
\DeclareUnicodeCharacter{8678}{$\!\fatslash$}
\DeclareUnicodeCharacter{8680}{$\fatbslash$}
\DeclareUnicodeCharacter{9671}{$\lozenge$}
\DeclareUnicodeCharacter{9633}{$\square$}
\DeclareUnicodeCharacter{9670}{$\blacklozenge$}
\DeclareUnicodeCharacter{9632}{$\blacksquare$}
\DeclareUnicodeCharacter{8639}{$\upharpoonleft$}
\DeclareUnicodeCharacter{8638}{$\upharpoonright$}
\DeclareUnicodeCharacter{8643}{$\downharpoonleft$}
\DeclareUnicodeCharacter{8642}{$\downharpoonright$}
\DeclareUnicodeCharacter{8242}{$'$}
\DeclareUnicodeCharacter{8801}{$\equiv$}
\DeclareUnicodeCharacter{8594}{$\rightarrow$}
\DeclareUnicodeCharacter{8802}{$\nequiv$}

\begin{document}
\begin{appendices}

\appendix
\renewcommand{\thesection}{A}
\section{Formalisation of NLQ in Agda}
In this appendix, we will discuss the Agda formalisation of
\emph{focused} NLQ. This section is written in literate Agda, and
includes \emph{all} of the code.
\begin{comment}
\begin{code}
module NLQ_Agda where
\end{code}
\end{comment}
\begin{comment}
\begin{code}
open import Level using (_⊔_)
\end{code}
\end{comment}
The order of presentation is different from the order used in the
thesis, due to constraints on the Agda language.

In the first part of this appendix, we will formalise the syntactic
calculus, NLQ. Then, in the second part, we will implement a
translation from proofs in NLQ to terms in Agda, giving us some form
of semantics. But first, we will discuss our motivation in deciding to
formalise our work.

\subsection{Motivation}
Why would we want to formalise type-logical grammars using proof
assistants? One good reason is that it allows us to write formally
verified proofs about the theoretical properties of our type-logical
grammars. But not only that---it allows us to directly run our proofs
as programs. For instance, we can directly run the translation from
NLQ to Agda, presented in this paper, to investigate what kind of
derivations result in what kind of semantics, \textit{and} be
confident in its correctness. In addition, we will be able to use any
interactive theorem prover that our proof assistant of choice provides
to experiment with and give proofs in our type-logical grammar.

Why, then, would we want to use Agda instead of a more established
proof assistant such as, for instance, Coq? There are several good
reasons, but we believe that the syntactic freedom offered by Agda is
the most important.
It is this freedom that allows us to write machine-checkable proofs,
formatted in a way which is very close to the way one would otherwise
typeset proofs, and which are highly readable compared to other
machine-checked proofs. This is true to a lesser extend for the
formalisation presented in this appendix, since we forgo a number of
features that generally make Agda code more readable in order to stay
as close as possible to the Haskell implementation in appendix B.
However, we do feel that, the Agda verification of the theory
presented here can be of great use in understanding thxe Haskell code.

The addition of these proofs means that we can be confident that the
proofs \textit{as they are published} are correct, and that they are
necessarily complete---for though we can hide some of the less
interesting definitions from the final paper, we cannot omit them from
the source.
In addition, some of the Agda proofs serve as explicit and fully
formal versions of proofs that were merely hinted at in the thesis.
Other Agda proofs serve as justification for Haskell functions which
circumvent the type-system---as Agda's type system is vastly more
powerful than that of Haskell.

Finally, because there is a correspondence between the published
proofs and the code, it becomes very easy for the reader to start up a
proof environment and inspect the proofs interactively in order to
further their understanding of the presented work.


\subsection{NLQ, Syntactic Calculus}
For our formalisation of NLQ, we are going to abstract over the atomic
types---a luxury offered by the Agda module system. The reason for
this is that the set of atomic types is more-or-less open---sometimes
we find out that we have to add a new one---and can be treated in a
uniform manner. Because atomic types must be assigned a polarity, we
will start out by defining a notion of polarity and polarised values:
\\[1\baselineskip]
\begin{code}
data Polarity : Set where
  + : Polarity
  - : Polarity

~_ : Polarity → Polarity
~ + = -
~ - = +

record Polarised (A : Set) : Set where
  field
    Pol : A → Polarity
open Polarised {{...}}
\end{code}
\\
We can now open our \AgdaModule{Syntax} module, abstracting over the
type of atomic types and a notion of polarisation for this type:
\\[1\baselineskip]
\begin{code}
module Syntax (Atom : Set) (PolarisedAtom : Polarised Atom) where
\end{code}
\begin{comment}
\begin{code}
  open import Data.Product using (∃; _,_)
  open import Function using (flip; const)
  open import Function.Equality using (_⟨$⟩_)
  open import Function.Equivalence as I using (_⇔_) renaming (equivalence to mkISO)
  open import Relation.Binary.PropositionalEquality as P using (_≡_; refl; inspect)
  open I.Equivalence using (from; to)
\end{code}
\end{comment}
\begin{comment}
\begin{code}
  private instance PolarisedAtomInst = PolarisedAtom
\end{code}
\end{comment}




\subsubsection{Types, Structures and Sequents}
First thing to do is to define our types. We abstract a little here:
instead of defining several copies of our rules for $\{\backslash,
\bullet, \slash\}$ and $\{\Diamond,\Box\}$ for new connectives, as we
did in the thesis, we define a datatype to represent the different
kinds of connectives we will be using, and parameterise our
connectives with a kind. We then recover the pretty versions of our
connectives using pattern synonyms. The advantage of this approach is
that we can later-on use e.g.\ the abstract right implication
\AgdaInductiveConstructor{ImpR} in the definitions of the inference
rules, defining all the copies at the same time.
\\[1\baselineskip]
\begin{code}
  data Strength : Set where
    Weak    : Strength
    Strong  : Strength

  data Kind : Set where
    Solid   : Kind             -- solid       {⇒, ∙, ⇐}
    Quan    : Strength → Kind  -- hollow      {⇨, ∘, ⇦}
    Del     : Strength → Kind  -- reset       {◇, □}
    Ifx     : Kind             -- extraction  {↿, ↾, ◇↑, □↑}
    Ext     : Kind             -- infixation  {⇃, ⇂, ◇↓, □↓}

  data Type : Set where
    El     : Atom  → Type
    Dia    : Kind  → Type  → Type
    Box    : Kind  → Type  → Type
    UnitL  : Kind  → Type  → Type
    ImpR   : Kind  → Type  → Type  → Type
    ImpL   : Kind  → Type  → Type  → Type
\end{code}
\begin{comment}
\begin{code}
  infixl 7 _⇐_ _⇦_
  infixr 7 _⇒_ _⇨_
  infix  7 _⇃_ _⇂_
  infix  7 _↿_ _↾_
  infixr 9 ◇_  □_ ◇↓_ □↓_ ◇↑_ □↑_
\end{code}
\end{comment}
\\[1\baselineskip]
\begin{code}
  pattern _⇐_  b a  = ImpL   Solid          b a
  pattern _⇒_  a b  = ImpR   Solid          a b
  pattern _⇨_  a b  = ImpR   (Quan Weak)    a b
  pattern _⇦_  b a  = ImpL   (Quan Weak)    b a
  pattern QW   a    = UnitL  (Quan Weak)    a
  pattern QS   a    = UnitL  (Quan Strong ) a
  pattern ◇_   a    = Dia    (Del Weak)   a
  pattern ◇↑_  a    = Dia    Ifx            a
  pattern ◇↓_  a    = Dia    Ext            a
  pattern □_   a    = Box    (Del Weak)   a
  pattern □↑_  a    = Box    Ifx            a
  pattern □↓_  a    = Box    Ext            a

  pattern _↿_  a b  = ◇↑ □↑ (a ⇒ b)
  pattern _↾_  b a  = ◇↑ □↑ (b ⇐ a)
  pattern _⇃_  a b  = (◇↓ □↓ a) ⇒ b
  pattern _⇂_  b a  = b ⇐ (◇↓ □↓ a)
\end{code}
\\
We use the same trick in defining structures, and merge Struct$^{+}$
and Struct$^{-}$ together into a single datatype indexed by a
polarity:
\\[1\baselineskip]
\begin{code}
  data Struct : Polarity → Set where
    ·_·   : ∀ {p} → Type → Struct p
    B     : Struct +
    C     : Struct +
    I*    : Struct +
    DIA   : Kind → Struct +  → Struct +
    UNIT  : Kind → Struct +
    PROD  : Kind → Struct +  → Struct +  → Struct +
    BOX   : Kind → Struct -  → Struct -
    IMPR  : Kind → Struct +  → Struct -  → Struct -
    IMPL  : Kind → Struct -  → Struct +  → Struct -
\end{code}
\begin{comment}
\begin{code}
  infixr 3 _∙_ _∘_
  infixr 9 ◆↓_ ■↓_ ◆↑_ ■↑_
\end{code}
\end{comment}
\\[1\baselineskip]
\begin{code}
  pattern _∙_   x y  = PROD   Solid         x y
  pattern _∘_   x y  = PROD   (Quan Weak)   x y
  pattern _∘ˢ_  x y  = PROD   (Quan Strong) x y
  pattern ⟨_⟩   x    = DIA    (Del Weak)    x
  pattern ⟨_⟩ˢ  x    = DIA    (Del Strong)  x
  pattern ◆↑_   x    = DIA    Ifx           x
  pattern ◆↓_   x    = DIA    Ext           x
  pattern I          = UNIT   (Quan Weak)
  pattern ■↑_   x    = BOX    Ifx           x
  pattern ■↓_   x    = BOX    Ext           x
\end{code}
\\
Since there is no pretty way to write the box we used for focusing in
Unicode, we will have to go with an ugly way:
\\[1\baselineskip]
\begin{comment}
\begin{code}
  infix 2 _⊢_ _⊢[_] [_]⊢_
\end{code}
\end{comment}
\begin{code}
  data Sequent : Set where
    _⊢_    : Struct +  → Struct -  → Sequent
    [_]⊢_  : Type      → Struct -  → Sequent
    _⊢[_]  : Struct +  → Type      → Sequent
\end{code}
\\
And finally, we need to extend our concept of polarity to
\emph{types}:
\\[1\baselineskip]
\begin{code}
  instance
    PolarisedType : Polarised Type
    PolarisedType = record { Pol = Pol′ }
      where
        Pol′ : Type → Polarity
        Pol′ (El    a)      = Pol(a)
        Pol′ (Dia   _ _)    = +
        Pol′ (Box   _ _)    = -
        Pol′ (UnitL _ _)    = +
        Pol′ (ImpR  _ _ _)  = -
        Pol′ (ImpL  _ _ _)  = -
\end{code}



\subsubsection{Inference Rules}
Below we define the logic of NLQ as a single datatype, indexed by a
sequent. As described in the section on focusing, the axioms and
focusing/unfocusing rules take an extra argument---a piece of evidence
for the polarity of the type \AgdaBound{a}/\AgdaBound{b}:
\\[1\baselineskip]
\begin{comment}
\begin{code}
  infix 1 NLQ_
\end{code}
\end{comment}
\begin{code}
  data NLQ_ : Sequent → Set where
    axElR   : ∀ {b}          → Pol(b) ≡ +  → NLQ · El b · ⊢[ El b ]
    axElL   : ∀ {a}          → Pol(a) ≡ -  → NLQ [ El a ]⊢ · El a ·
    unfR    : ∀ {x b}        → Pol(b) ≡ -  → NLQ x ⊢ · b ·  → NLQ x ⊢[ b ]
    unfL    : ∀ {a y}        → Pol(a) ≡ +  → NLQ · a · ⊢ y  → NLQ [ a ]⊢ y
    focR    : ∀ {x b}        → Pol(b) ≡ +  → NLQ x ⊢[ b ]   → NLQ x ⊢ · b ·
    focL    : ∀ {a y}        → Pol(a) ≡ -  → NLQ [ a ]⊢ y   → NLQ · a · ⊢ y

    impRL   : ∀ {k x y a b}  → NLQ x ⊢[ a ]  → NLQ [ b ]⊢ y  → NLQ [ ImpR k a b ]⊢ IMPR k x y
    impRR   : ∀ {k x a b}    → NLQ x ⊢ IMPR k · a · · b ·   → NLQ x ⊢ · ImpR k a b ·
    impLL   : ∀ {k x y a b}  → NLQ x ⊢[ a ]  → NLQ [ b ]⊢ y  → NLQ [ ImpL k b a ]⊢ IMPL k y x
    impLR   : ∀ {k x a b}    → NLQ x ⊢ IMPL k · b · · a ·   → NLQ x ⊢ · ImpL k b a ·
    resRP   : ∀ {k x y z}    → NLQ y ⊢ IMPR k x z  → NLQ PROD k x y ⊢ z
    resPR   : ∀ {k x y z}    → NLQ PROD k x y ⊢ z  → NLQ y ⊢ IMPR k x z
    resLP   : ∀ {k x y z}    → NLQ x ⊢ IMPL k z y  → NLQ PROD k x y ⊢ z
    resPL   : ∀ {k x y z}    → NLQ PROD k x y ⊢ z  → NLQ x ⊢ IMPL k z y

    diaL    : ∀ {k a y}      → NLQ DIA k · a · ⊢ y  → NLQ · Dia k a · ⊢ y
    diaR    : ∀ {k x b}      → NLQ x ⊢[ b ]         → NLQ DIA k x ⊢[ Dia k b ]
    boxL    : ∀ {k a y}      → NLQ [ a ]⊢ y         → NLQ [ Box k a ]⊢ BOX k y
    boxR    : ∀ {k x b}      → NLQ x ⊢ BOX k · b ·  → NLQ x ⊢ · Box k b ·
    resBD   : ∀ {k x y}      → NLQ x ⊢ BOX k y      → NLQ DIA k x ⊢ y
    resDB   : ∀ {k x y}      → NLQ DIA k x ⊢ y      → NLQ x ⊢ BOX k y

    unitLL  : ∀ {k y a}      → NLQ PROD k (UNIT k) · a · ⊢ y → NLQ · UnitL k a · ⊢ y
    unitLR  : ∀ {k x b}      → NLQ x ⊢[  b ]  → NLQ PROD k (UNIT k) x ⊢[ UnitL k b ]
    unitLI  : ∀ {k x y}      → NLQ x ⊢   y    → NLQ PROD k (UNIT k) x ⊢ y

    dnB     : ∀ {x y z w k}  → NLQ x ∙ (PROD (Quan k) y z) ⊢ w
            → NLQ PROD (Quan k) ((B ∙ x) ∙ y) z ⊢ w
    upB     : ∀ {x y z w k}  → NLQ PROD (Quan k) ((B ∙ x) ∙ y) z ⊢ w
            → NLQ x ∙ (PROD (Quan k) y z) ⊢ w
    dnC     : ∀ {x y z w k}  → NLQ (PROD (Quan k) x y) ∙ z ⊢ w
            → NLQ PROD (Quan k) ((C ∙ x) ∙ z) y ⊢ w
    upC     : ∀ {x y z w k}  → NLQ PROD (Quan k) ((C ∙ x) ∙ z) y ⊢ w
            → NLQ (PROD (Quan k) x y) ∙ z ⊢ w
    upI*    : ∀ {x y w}      → NLQ ((I* ∙ ⟨ x ⟩) ∘ˢ y ⊢ w) → NLQ (⟨ x ∘ˢ y ⟩ ⊢ w)
    dnI*    : ∀ {x y w}      → NLQ (⟨ x ∘ˢ y ⟩ ⊢ w) → NLQ ((I* ∙ ⟨ x ⟩) ∘ˢ y ⊢ w)

    ifxRR   : ∀ {x y z w}    → NLQ ((x ∙ y) ∙ ◆↑ z ⊢ w)  → NLQ (x ∙ (y ∙ ◆↑ z) ⊢ w)
    ifxLR   : ∀ {x y z w}    → NLQ ((x ∙ y) ∙ ◆↑ z ⊢ w)  → NLQ ((x ∙ ◆↑ z) ∙ y ⊢ w)
    ifxLL   : ∀ {x y z w}    → NLQ (◆↑ z ∙ (y ∙ x) ⊢ w)  → NLQ ((◆↑ z ∙ y) ∙ x ⊢ w)
    ifxRL   : ∀ {x y z w}    → NLQ (◆↑ z ∙ (y ∙ x) ⊢ w)  → NLQ (y ∙ (◆↑ z ∙ x) ⊢ w)

    extRR   : ∀ {x y z w}    → NLQ (x ∙ (y ∙ ◆↓ z) ⊢ w)  → NLQ ((x ∙ y) ∙ ◆↓ z ⊢ w)
    extLR   : ∀ {x y z w}    → NLQ ((x ∙ ◆↓ z) ∙ y ⊢ w)  → NLQ ((x ∙ y) ∙ ◆↓ z ⊢ w)
    extLL   : ∀ {x y z w}    → NLQ ((◆↓ z ∙ y) ∙ x ⊢ w)  → NLQ (◆↓ z ∙ (y ∙ x) ⊢ w)
    extRL   : ∀ {x y z w}    → NLQ (y ∙ (◆↓ z ∙ x) ⊢ w)  → NLQ (◆↓ z ∙ (y ∙ x) ⊢ w)
\end{code}
\\
Using these axiomatic rules, we can define derived rules. For
instance, we can define the following ``residuation'' rules, which
convert left implication to right implication, and vice versa:
\\[1\baselineskip]
\begin{code}
  resRL : ∀ {k x y z} → NLQ y ⊢ IMPR k x z → NLQ x ⊢ IMPL k z y
  resRL f = resPL (resRP f)

  resLR : ∀ {k x y z} → NLQ x ⊢ IMPL k z y → NLQ y ⊢ IMPR k x z
  resLR f = resPR (resLP f)
\end{code}


\subsubsection{Contexts and Plugging functions}
NLQ might not need contexts and plugging functions for its
specification, but many meta-logical proofs nonetheless require this
vocabulary.
In preparation for the proof in the following section, We will
therefore define a notion of contexts for NLQ.
We start by defining contexts an class of ``pluggable''' things:
\\[1\baselineskip]
\begin{code}
  record Pluggable (C I O : Set) : Set where
    field
      _[_] : C → I → O
  open Pluggable {{...}}
\end{code}
\\
Next, we define the first type of context: full structural
contexts, i.e.\ structures with a single hole. For this, we simply
replicate the structure of contexts, and add the
\AgdaInductiveConstructor{HOLE}-constructor. Note that we replicate
binary constructors twice---once with the hole to the left, and once
with the hole to the right:
\\[1\baselineskip]
\begin{code}
  data StructCtxt (p : Polarity) : Polarity → Set where
    HOLE   : StructCtxt p p
    DIA1   : Kind → StructCtxt p  +  → StructCtxt p  +
    PROD1  : Kind → StructCtxt p  +  → Struct        +  → StructCtxt p  +
    PROD2  : Kind → Struct        +  → StructCtxt p  +  → StructCtxt p  +
    BOX1   : Kind → StructCtxt p  -  → StructCtxt p  -
    IMPR1  : Kind → StructCtxt p  +  → Struct        -  → StructCtxt p  -
    IMPR2  : Kind → Struct        +  → StructCtxt p  -  → StructCtxt p  -
    IMPL1  : Kind → StructCtxt p  -  → Struct        +  → StructCtxt p  -
    IMPL2  : Kind → Struct        -  → StructCtxt p  +  → StructCtxt p  -
\end{code}
\\
Plugging is simply the process of taking a given structure, and
inserting this in place of the hole:
\\[1\baselineskip]
\begin{code}
  instance
    Pluggable-Struct : ∀ {p1 p2} → Pluggable (StructCtxt p1 p2) (Struct p1) (Struct p2)
    Pluggable-Struct = record { _[_] = _[_]′ }
      where
        _[_]′ : ∀ {p1 p2} → StructCtxt p1 p2 → Struct p1 → Struct p2
        ( HOLE          ) [ z ]′ = z
        ( DIA1   k x    ) [ z ]′ = DIA   k    (x [ z ]′)
        ( PROD1  k x y  ) [ z ]′ = PROD  k    (x [ z ]′) y
        ( PROD2  k x y  ) [ z ]′ = PROD  k x  (y [ z ]′)
        ( BOX1   k x    ) [ z ]′ = BOX   k    (x [ z ]′)
        ( IMPR1  k x y  ) [ z ]′ = IMPR  k    (x [ z ]′) y
        ( IMPR2  k x y  ) [ z ]′ = IMPR  k x  (y [ z ]′)
        ( IMPL1  k x y  ) [ z ]′ = IMPL  k    (x [ z ]′) y
        ( IMPL2  k x y  ) [ z ]′ = IMPL  k x  (y [ z ]′)
\end{code}
\\
In accordance with our approach in the previous sections, we recover
more specific (and prettier) context-constructors using pattern
synonyms:
\\[1\baselineskip]
\begin{code}
  pattern _<∙_  x y  = PROD1  Solid         x y
  pattern _<⇒_  x y  = IMPR2  Solid         x y
  pattern _<⇐_  y x  = IMPL1  Solid         y x
  pattern _<∘_  x y  = PROD1  (Quan Weak)   x y
  pattern _<⇨_  x y  = IMPR1  (Quan Weak)   x y
  pattern _<⇦_  y x  = IMPL1  (Quan Weak)   y x
  pattern _∙>_  x y  = PROD2  Solid         x y
  pattern _⇒>_  x y  = IMPR2  Solid         x y
  pattern _⇐>_  y x  = IMPL1  Solid         y x
  pattern _∘>_  x y  = PROD2  (Quan Weak)   x y
  pattern _⇨>_  x y  = IMPR2  (Quan Weak)   x y
  pattern _⇦>_  y x  = IMPL2  (Quan Weak)   y x
  pattern ◆>_   x    = DIA1   (Del Weak)    x
  pattern ◆↓>_  x    = DIA1   Ifx           x
  pattern ◆↑>_  x    = DIA1   Ext           x
  pattern ■>_   x    = BOX1   (Del Weak)    x
  pattern ■↓>_  x    = BOX1   Ifx           x
  pattern ■↑>_  x    = BOX1   Ext           x
\end{code}
\\
And we do the same for sequents:
\\[1\baselineskip]
\begin{code}
  data SequentCtxt (p : Polarity) : Set where
    _<⊢_  : StructCtxt p  + → Struct        - → SequentCtxt p
    _⊢>_  : Struct        + → StructCtxt p  - → SequentCtxt p

  instance
    Pluggable-Sequent : ∀ {p} → Pluggable (SequentCtxt p) (Struct p) Sequent
    Pluggable-Sequent = record { _[_] = _[_]′ }
      where
        _[_]′ : ∀ {p} → SequentCtxt p → Struct p → Sequent
        (x <⊢ y)  [ z ]′ = x [ z ] ⊢ y
        (x ⊢> y)  [ z ]′ = x ⊢ y [ z ]
\end{code}



\subsubsection{Display Property}
In this section, we will prove that NLQ has the display
property. Before we can do this, we will define one more type of
context: a display context. This is a context where the inserted
structure is always guaranteed to end up at the top-level:
\\[1\baselineskip]
\begin{code}
  data DisplayCtxt : Polarity → Set where
    <⊢_  : Struct -  → DisplayCtxt +
    _⊢>  : Struct +  → DisplayCtxt -

  instance
    Pluggable-Display : ∀ {p} → Pluggable (DisplayCtxt p) (Struct p) Sequent
    Pluggable-Display = record { _[_] = _[_]′ }
      where
        _[_]′ : ∀ {p} → DisplayCtxt p → Struct p → Sequent
        (<⊢ y)  [ x ]′  = x ⊢ y
        (x ⊢>)  [ y ]′  = x ⊢ y
\end{code}
\\
Now we can defined \AgdaFunction{DP}: a type-level function, which
takes a sequent context and computes a display context in which the
structure that would be in the hole of the sequent context is
displayed (i.e. brought to the top-level).

This is implemented with two functions, \AgdaFunction{DPL} and
\AgdaFunction{DPR}, which manipulate the antecedent and succedent. By
splitting up the sequent in two arguments---the antecedent and the
succedent---these functions become structurally recursive. Note that
what these functions encode is basically the relations established by
residuation:
\\[1\baselineskip]
\begin{code}
  mutual
    DP : ∀ {p} (s : SequentCtxt p) → DisplayCtxt p
    DP (x <⊢ y) = DPL x y
    DP (x ⊢> y) = DPR x y

    DPL : ∀ {p} (x : StructCtxt p +) (y : Struct -) → DisplayCtxt p
    DPL ( HOLE          ) z = <⊢ z
    DPL ( DIA1   k x    ) z = DPL x  ( BOX   k z    )
    DPL ( PROD1  k x y  ) z = DPL x  ( IMPL  k z y  )
    DPL ( PROD2  k x y  ) z = DPL y  ( IMPR  k x z  )

    DPR : ∀ {p} (x : Struct +) (y : StructCtxt p -) → DisplayCtxt p
    DPR x  ( HOLE          ) = x ⊢>
    DPR x  ( BOX1   k y    ) = DPR    ( DIA   k x    ) y
    DPR x  ( IMPR1  k y z  ) = DPL y  ( IMPL  k z x  )
    DPR x  ( IMPR2  k y z  ) = DPR    ( PROD  k y x  ) z
    DPR x  ( IMPL1  k z y  ) = DPR    ( PROD  k x y  ) z
    DPR x  ( IMPL2  k z y  ) = DPL y  ( IMPR  k x z  )
\end{code}
\\
The actual displaying is done by the term-level function
\AgdaFunction{dp}. This function takes a sequent context $s$ (as
above), a structure $w$, and a proof for the sequent $s [ w ]$. It
then computes an isomorphism between proofs of $s [ w ]$ and proofs of
$\AgdaFunction{DP}(s)[ w ]$ where, in the second proof, the structure
$w$ is guaranteed  to be displayed:\footnote{%
  In the definition of \AgdaFunction{dp} we use some definitions from
  the Agda standard library, related to isomorphisms, found under
  \AgdaFunction{Function.Equivalence}. An isomorphism is written
  \AgdaFunction{⇔}, and created with \AgdaFunction{mkISO}---which was
  renamed from \AgdaFunction{equivalence}. Identity and composition
  are written as usual, with the module prefix \AgdaFunction{I}.
  Application is written with a combination of
  \AgdaField{from}/\AgdaField{to} and \AgdaFunction{⟨\$⟩}.
}
\\[1\baselineskip]
\begin{code}
  mutual
    dp : ∀ {p} (s : SequentCtxt p) (w : Struct p) → (NLQ s [ w ]) ⇔ (NLQ DP(s)[ w ])
    dp (x <⊢ y) w = dpL x y w
    dp (x ⊢> y) w = dpR x y w

    dpL  : ∀ {p} (x : StructCtxt p +) (y : Struct -) (w : Struct p)
         → (NLQ x [ w ] ⊢ y) ⇔ (NLQ DPL x y [ w ])
    dpL ( HOLE          )  z w = I.id
    dpL ( DIA1   k x    )  z w = dpL x  ( BOX   k z    )  w I.∘ mkISO resDB resBD
    dpL ( PROD1  k x y  )  z w = dpL x  ( IMPL  k z y  )  w I.∘ mkISO resPL resLP
    dpL ( PROD2  k x y  )  z w = dpL y  ( IMPR  k x z  )  w I.∘ mkISO resPR resRP

    dpR  : ∀ {p} (x : Struct +) (y : StructCtxt p -) (w : Struct p)
         → (NLQ x ⊢ y [ w ]) ⇔ (NLQ DPR x y [ w ])
    dpR x ( HOLE          ) w = I.id
    dpR x ( BOX1   k y    ) w = dpR    ( DIA   k x    ) y  w I.∘ mkISO resBD resDB
    dpR x ( IMPR1  k y z  ) w = dpL y  ( IMPL  k z x  )    w I.∘ mkISO resRL resLR
    dpR x ( IMPR2  k y z  ) w = dpR    ( PROD  k y x  ) z  w I.∘ mkISO resRP resPR
    dpR x ( IMPL1  k z y  ) w = dpR    ( PROD  k x y  ) z  w I.∘ mkISO resLP resPL
    dpR x ( IMPL2  k z y  ) w = dpL y  ( IMPR  k x z  )    w I.∘ mkISO resLR resRL
\end{code}
\\
Note that while they are defined under a \AgdaKeyword{mutual}-keyword,
these functions are not mutually recursive---however, if the logic NLQ
contained e.g.\ subtractive types as found in LG, they would be.

Below we define \AgdaFunction{dp1} and \AgdaFunction{dp2}, which are
helper functions. These functions allow you to access the two sides of
the isomorphism more easily:
\\[1\baselineskip]
\begin{code}
  dp1 : ∀ {p} (s : SequentCtxt p) {w : Struct p} → NLQ s [ w ] → NLQ DP(s)[ w ]
  dp1 s {w} f = to (dp s w) ⟨$⟩ f

  dp2 : ∀ {p} (s : SequentCtxt p) {w : Struct p} → NLQ DP(s)[ w ] → NLQ s [ w ]
  dp2 s {w} f = from (dp s w) ⟨$⟩ f
\end{code}



\subsubsection{Structuralising Types}
Because each logical connective has a structural equivalent, it is
possible---to a certain extend---structuralise logical connectives
en masse. The function \AgdaFunction{St} takes a type, and computes
the maximally structuralised version of that type, given a target
polarity $p$:
\\[1\baselineskip]
\begin{code}
  St : ∀ {p} → Type → Struct p
  St { p = + } ( Dia    k  a   )  = DIA   k (St a)
  St { p = - } ( Box    k  a   )  = BOX   k (St a)
  St { p = + } ( UnitL  k  a   )  = PROD  k (UNIT k) (St a)
  St { p = - } ( ImpR   k  a b )  = IMPR  k (St a) (St b)
  St { p = - } ( ImpL   k  b a )  = IMPL  k (St b) (St a)
  St { p = _ } a                  = · a ·
\end{code}
\\
We know that if we try to structuralise a positive type as a negative
structure, or vice versa, it results in the primitive structure. The
lemma \AgdaFunction{lem-St} encodes this knowledge:
\\[1\baselineskip]
\begin{code}
  lem-St : ∀ {p} a → Pol(a) ≡ ~ p → St {p} a ≡ · a ·
  lem-St { + } ( El      a    ) pr = refl
  lem-St { - } ( El      a    ) pr = refl
  lem-St { + } ( Dia   k a    ) ()
  lem-St { - } ( Dia   k a    ) pr = refl
  lem-St { + } ( Box   k a    ) pr = refl
  lem-St { - } ( Box   k a    ) ()
  lem-St { + } ( UnitL k a    ) ()
  lem-St { - } ( UnitL k a    ) pr = refl
  lem-St { + } ( ImpR  k a b  ) pr = refl
  lem-St { - } ( ImpR  k a b  ) ()
  lem-St { + } ( ImpL  k b a  ) pr = refl
  lem-St { - } ( ImpL  k b a  ) ()
\end{code}
\\
The functions \AgdaFunction{st}, \AgdaFunction{stL} and
\AgdaFunction{stR} actually perform the structuralisation described by
\AgdaFunction{St}. Given a proof for a sequent $s$, they will
structuralise either the antecedent, the succedent, or both:
\\[1\baselineskip]
\begin{code}
  mutual
    st : ∀ {a b} → NLQ St a ⊢ St b → NLQ · a · ⊢ · b ·
    st f = stL (stR f)

    stL : ∀ {a y} → NLQ St a ⊢ y → NLQ · a · ⊢ y
    stL { a = El        a    } f = f
    stL { a = Dia    k  a    } f = diaL (resBD (stL (resDB f)))
    stL { a = Box    k  a    } f = f
    stL { a = UnitL  k  a    } f = unitLL (resRP (stL (resPR f)))
    stL { a = ImpR   k  a b  } f = f
    stL { a = ImpL   k  b a  } f = f

    stR : ∀ {x b} → NLQ x ⊢ St b → NLQ x ⊢ · b ·
    stR { b = El        a    } f = f
    stR { b = Dia    k  a    } f = f
    stR { b = Box    k  a    } f = boxR (resDB (stR (resBD f)))
    stR { b = UnitL  k  a    } f = f
    stR { b = ImpR   k  a b  } f = impRR (resPR (stR (resLP (stL (resPL (resRP f))))))
    stR { b = ImpL   k  b a  } f = impLR (resPL (stR (resRP (stL (resPR (resLP f))))))
\end{code}




\subsubsection{Identity Expansion}
Another important proof is `identity expansion'---the proof
that tells us that although we have restricted the axioms to atomic
types, we can still derive the full identity rule.
The inclusion of focusing makes this proof slightly more complex, as
between the introduction of the connectives, we have to structuralise
and occasionally switch focus.

In the below proof, \AgdaFunction{axR} and \AgdaFunction{axL}
recursively apply the rules for symmetric introduction---through
\AgdaFunction{axR′} and \AgdaFunction{axL′}---until there is
a clash in polarity---which is defined as applying \AgdaFunction{axR}
to a negative type or vice versa---at which point they switch focus,
structuralise, and continue:\footnote{%
  In the definition of \AgdaFunction{ax}, \AgdaFunction{axR} and
  \AgdaFunction{axL} we use \AgdaFunction{inspect}, which allows you
  to apply a function \AgdaBound{f} to an argument \AgdaBound{x} to
  obtain \AgdaBound{y}, and obtain an explicit proof that
  \AgdaBound{f} \AgdaBound{x} \AgdaFunction{≡} \AgdaBound{y}.
  The function \AgdaFunction{inspect} is defined in
  \AgdaFunction{Relation.Binary.PropositionalEquality}.
}
\\[1\baselineskip]
\begin{code}
  mutual
    ax : ∀ {a} → NLQ · a · ⊢ · a ·
    ax {a} with Pol(a) | inspect Pol(a)
    ... | + | P.[ p ]  rewrite lem-St  a p  = stL (focR p (axR′ p))
    ... | - | P.[ n ]  rewrite lem-St  a n  = stR (focL n (axL′ n))

    axR : ∀ {b} → NLQ St b ⊢[ b ]
    axR {b} with Pol(b) | inspect Pol(b)
    ... | + | P.[ p ]                       = axR′ p
    ... | - | P.[ n ]  rewrite lem-St  b n  = unfR n (stR (focL n (axL′ n)))

    axL : ∀ {a} → NLQ [ a ]⊢ St a
    axL {a} with Pol(a) | inspect Pol(a)
    ... | + | P.[ p ]  rewrite lem-St  a p  = unfL p (stL (focR p (axR′ p)))
    ... | - | P.[ n ]                       = axL′ n

    axR′ : ∀ {b} → Pol(b) ≡ + → NLQ St b ⊢[ b ]
    axR′ { b = El        a    } p = axElR p
    axR′ { b = Dia    k  a    } p = diaR axR
    axR′ { b = Box    k  a    } ()
    axR′ { b = UnitL  k  a    } p = unitLR axR
    axR′ { b = ImpR   k  a b  } ()
    axR′ { b = ImpL   k  b a  } ()

    axL′ : ∀ {a} → Pol(a) ≡ - → NLQ [ a ]⊢ St a
    axL′ { a = El        a    } n = axElL n
    axL′ { a = Dia    k  a    } ()
    axL′ { a = Box    k  a    } n = boxL axL
    axL′ { a = UnitL  k  a    } ()
    axL′ { a = ImpR   k  a b  } n = impRL axR axL
    axL′ { a = ImpL   k  b a  } n = impLL axR axL
\end{code}

\subsubsection{Quanfitier Raising}
In this section, we show that $\mathbf{Q}\uparrow$ and
$\mathbf{Q}\downarrow$ are indeed derivable in the calculus NLQ. For
this, we define yet another type of context: the
\AgdaFunction{∙-Ctxt}, i.e.\ contexts made up solely out of solid
products:
\\[1\baselineskip]
\begin{code}
  data ∙-Ctxt : Set where
    HOLE   : ∙-Ctxt
    PROD1  : ∙-Ctxt    → Struct +  → ∙-Ctxt
    PROD2  : Struct +  → ∙-Ctxt    → ∙-Ctxt

  instance
    Pluggable-∙ : Pluggable ∙-Ctxt (Struct +) (Struct +)
    Pluggable-∙ = record { _[_] = _[_]′ }
      where
        _[_]′ : ∙-Ctxt → Struct + → Struct +
        ( HOLE        ) [ z ]′ = z
        ( PROD1  x y  ) [ z ]′ = PROD Solid    (x [ z ]′) y
        ( PROD2  x y  ) [ z ]′ = PROD Solid x  (y [ z ]′)
\end{code}
\\
For these contexts, we can define the \AgdaFunction{trace} function,
which inserts the correct trace of \textbf{I}'s, \textbf{B}'s and
\textbf{C}'s:
\\[1\baselineskip]
\begin{code}
  trace : ∙-Ctxt → Struct +
  trace ( HOLE        )  = UNIT (Quan Weak)
  trace ( PROD1  x y  )  = PROD Solid (PROD Solid C (trace x)) y
  trace ( PROD2  x y  )  = PROD Solid (PROD Solid B x) (trace y)
\end{code}
\\
And using the \AgdaFunction{trace} function, we can define upwards and
downwards quantifier movement:
\\[1\baselineskip]
\begin{code}
  qL : ∀ {y b c} → ∀ x → NLQ trace(x) ⊢[ b ] → NLQ [ c ]⊢ y → NLQ x [ · QW (b ⇨ c) · ] ⊢ y
  qL x f g = ↑ x (resRP (focL refl (impRL f g)))
    where
    ↑ : ∀ {a z} x → NLQ trace(x) ∘ · a · ⊢ z → NLQ x [ · QW a · ] ⊢ z
    ↑ x f = init x (move x f)
      where
      init  : ∀ {a z} (x : ∙-Ctxt) → NLQ x [ I ∘ · a · ] ⊢ z → NLQ x [ · QW a · ] ⊢ z
      init  ( HOLE        ) f = unitLL f
      init  ( PROD1  x y  ) f = resLP (init x (resPL f))
      init  ( PROD2  x y  ) f = resRP (init y (resPR f))
      move  : ∀ {y z} (x : ∙-Ctxt) → NLQ trace(x) ∘ y ⊢ z → NLQ x [ I ∘ y ] ⊢ z
      move  ( HOLE        ) f = f
      move  ( PROD1  x y  ) f = resLP (move x (resPL (upC f)))
      move  ( PROD2  x y  ) f = resRP (move y (resPR (upB f)))

  qR : ∀ {a b} → ∀ x → NLQ x [ · a · ] ⊢ · b · → NLQ trace(x) ⊢ · b ⇦ a ·
  qR x f = impLR (resPL (↓ x f))
    where
    ↓ : ∀ {y z} x → NLQ x [ y ] ⊢ z → NLQ trace(x) ∘ y ⊢ z
    ↓ ( HOLE        ) f = unitLI f
    ↓ ( PROD1  x y  ) f = dnC (resLP (↓ x (resPL f)))
    ↓ ( PROD2  x y  ) f = dnB (resRP (↓ y (resPR f)))
\end{code}
\\
These compose to form full quantifier movement:
\\[1\baselineskip]
\begin{code}
  q  : (x : ∙-Ctxt) → ∀ {y a b c}
     → NLQ x [ · a · ] ⊢ · b ·
     → NLQ [ c ]⊢ y
     → NLQ x [ · QW ((b ⇦ a) ⇨ c) · ] ⊢ y
  q x f g  = qL x (unfR refl (qR x f)) g
\end{code}


\subsubsection{Infixation and Reasoning with Gaps}
The final type of movement to discuss is the derived version of the
R$_{rgap}$ rules used by Barker and Shan (2015). First we will
formalise the right infixation, allowing a structure with an
infixation licence to move downwards past solid products:
\\[1\baselineskip]
\begin{code}
  extR : ∀ {y z w} (x : ∙-Ctxt) → NLQ x [ y ∙ ◆↓ z ] ⊢ w → NLQ x [ y ] ∙ ◆↓ z ⊢ w
  extR ( HOLE        ) f = f
  extR ( PROD1  x y  ) f = extLR (resLP (extR x (resPL f)))
  extR ( PROD2  x y  ) f = extRR (resRP (extR y (resPR f)))
\end{code}
\\
However, here we run into a slight problem. In this formalisation, we
use focusing. However, we do not have a full adaptation of the
normalisation procedure from display NLQ to focused NLQ to NLQ.
In order to fully encode Barker and Shan's rule, we would have to
infixate and then \emph{remove} the license. However, removing the
license \emph{in this context} is only possible in the case where the
type under the licence is positive. So, without problems, we can
define the following version of the rule:
\\[1\baselineskip]
\begin{code}
  r⇂⁺  : ∀ {y b c} (x : ∙-Ctxt) (pr : Pol(b) ≡ +)
       → NLQ x [ y ∙ · b · ] ⊢ · c · →  NLQ x [ y ] ⊢ · c ⇂ b ·
  r⇂⁺ {y} {b} x pr f = impLR (resPL (resRP (diaL (resPR (extR x (stop x f))))))
    where
    stop : ∀ {z} (x : ∙-Ctxt) → NLQ x [ y ∙ · b · ] ⊢ z → NLQ x [ y ∙ ◆↓ · □↓ b · ] ⊢ z
    stop ( HOLE        ) f = resRP (resBD (focL refl (boxL (unfL pr (resPR f)))))
    stop ( PROD1  x y  ) f = resLP (stop x (resPL f))
    stop ( PROD2  x y  ) f = resRP (stop y (resPR f))
\end{code}
\\
However, in the case where the type under the licence is negative, we
will have to use the following, more general rule which leaves the
license in place, and then remove it at a later stage in the proof:
\\[1\baselineskip]
\begin{code}
  r⇂ : ∀ {y b c} (x : ∙-Ctxt) → NLQ x [ y ∙ ◆↓ · □↓ b · ] ⊢ · c · →  NLQ x [ y ] ⊢ · c ⇂ b ·
  r⇂ x f = impLR (resPL (resRP (diaL (resPR (extR x f)))))
\end{code}
\\
The proofs for left infixation, and extraction can be done in a
similar manner.


\subsection{Semantics in Agda}
Having formalised the syntactic calculus NLQ in the first part, we
will now briefly turn our attention towards a semantics. Instead of
formalising $\lambda^{\rightarrow}_{\{\mathbf{e},\mathbf{t}\}}$, we
will give the semantics for NLQ in Agda---it looks much nicer, and is
much less work, even if $\lambda\Pi$ is a little bit more expressive
than strictly necessary.

We will give our semantics in a separate module, which will---once
again---be abstracting over atomic types and their polarity. In
addition to this, we now have to abstract over a translation from atomic
types to semantic types. For this, we define the following class of
translations:
\\[1\baselineskip]
\begin{code}
record Translate {t1 t2} (T1 : Set t1) (T2 : Set t2) : Set (t1 ⊔ t2) where
  field
    _* : T1 → T2
open Translate {{...}}
\end{code}
\\
And abstract accordingly:
\\[1\baselineskip]
\begin{code}
module Semantics
  (Atom : Set)
  (PolarisedAtom   : Polarised Atom)
  (TranslateAtom   : Translate Atom Set)
  where
\end{code}
\begin{comment}
\begin{code}
  open import Function     using (id; flip; _∘_)
  open import Data.Unit    using (⊤; tt)
  open import Data.Product using (_×_; _,_)
  open module NLQ = Syntax Atom PolarisedAtom hiding (_∘_)
\end{code}
\end{comment}
\begin{comment}
\begin{code}
  private instance PolarisedAtomInst = PolarisedAtom
  private instance TranslateAtomInst = TranslateAtom
\end{code}
\end{comment}
\\
The translation on types, structures and sequents is rather
simple. Instead of translating sequents to sequents, we will translate
them to function types. Implications too, both logical and structural,
become function types. Otherwise, products become products, units
becomes units, etc.
\\[1\baselineskip]
\begin{code}
  instance
    TranslateType : Translate Type Set
    TranslateType = record { _* = _*′ }
      where
        _*′ : Type → Set
        El        a    *′ = a *
        Dia    _  a    *′ = a *′
        Box    _  a    *′ = a *′
        UnitL  _  a    *′ = a *′
        ImpR   _  a b  *′ = a *′ → b *′
        ImpL   _  b a  *′ = a *′ → b *′

    TranslateStruct : ∀ {p} → Translate (Struct p) Set
    TranslateStruct = record { _* = _*′ }
      where
        _*′ : ∀ {p} → Struct p → Set
        · a ·         *′ = a *
        B             *′ = ⊤
        C             *′ = ⊤
        I*            *′ = ⊤
        DIA   _  x    *′ = x *′
        UNIT  _       *′ = ⊤
        PROD  _  x y  *′ = x *′ × y *′
        BOX   _  x    *′ = x *′
        IMPR  _  x y  *′ = x *′ → y *′
        IMPL  _  y x  *′ = x *′ → y *′

    TranslateSequent : Translate Sequent Set
    TranslateSequent = record { _* = _*′ }
      where
        _*′ : Sequent → Set
        ( x ⊢ y     )*′ = x * → y *
        ( [ a ]⊢ y  )*′ = a * → y *
        ( x ⊢[ b ]  )*′ = x * → b *
\end{code}
\\
Finally, using our translation on sequents, we can implement the
translation on proofs:
\\[1\baselineskip]
\begin{code}
  instance
    TranslateProof : ∀ {s} → Translate (NLQ s) (s *)
    TranslateProof = record { _* = _*′ }
      where
        _*′ : ∀ {s} → NLQ s → s *
        axElR _      *′ = λ x → x
        axElL _      *′ = λ x → x
        unfR  _ f    *′ = f *′
        unfL  _ f    *′ = f *′
        focR  _ f    *′ = f *′
        focL  _ f    *′ = f *′
        impRL   f g  *′ = λ h → g *′ ∘ h ∘ f *′
        impRR   f    *′ = f *′
        impLL   f g  *′ = λ h → g *′ ∘ h ∘ f *′
        impLR   f    *′ = f *′
        resRP   f    *′ = λ{ (x , y)  → (f *′)  y   x          }
        resLP   f    *′ = λ{ (x , y)  → (f *′)  x   y          }
        resPR   f    *′ = λ{  y   x   → (f *′) (x , y)         }
        resPL   f    *′ = λ{  x   y   → (f *′) (x , y)         }
        diaL    f    *′ = f *′
        diaR    f    *′ = f *′
        boxL    f    *′ = f *′
        boxR    f    *′ = f *′
        resBD   f    *′ = f *′
        resDB   f    *′ = f *′
        unitLL  f    *′ = λ{  x                   → (f *′) (_ , x)              }
        unitLR  f    *′ = λ{ (_ , x)              → (f *′)  x                   }
        unitLI  f    *′ = λ{ (_ , x)              → (f *′)  x                   }
        dnB     f    *′ = λ{ (((_ , x) , y) , z)  → (f *′) (x , (y , z))        }
        dnC     f    *′ = λ{ (((_ , x) , z) , y)  → (f *′) ((x , y) , z)        }
        dnI*    f    *′ = λ{  ((_ , x) , y)       → (f *′) (x , y)              }
        upB     f    *′ = λ{ ( x , y  , z)        → (f *′) (((_ , x) , y) , z)  }
        upC     f    *′ = λ{ ((x , y) , z)        → (f *′) (((_ , x) , z) , y)  }
        upI*    f    *′ = λ{  (x , y)             → (f *′) ((_ , x) , y)        }
        ifxRR   f    *′ = λ{ ( x , y  , z)        → (f *′) ((x , y) , z)        }
        ifxLR   f    *′ = λ{ ((x , z) , y)        → (f *′) ((x , y) , z)        }
        ifxLL   f    *′ = λ{ ((z , y) , x)        → (f *′) ( z , y  , x)        }
        ifxRL   f    *′ = λ{ ( y , z  , x)        → (f *′) ( z , y  , x)        }
        extRR   f    *′ = λ{ ((x , y) , z)        → (f *′) ( x , y  , z)        }
        extLR   f    *′ = λ{ ((x , y) , z)        → (f *′) ((x , z) , y)        }
        extLL   f    *′ = λ{ ( z , y  , x)        → (f *′) ((z , y) , x)        }
        extRL   f    *′ = λ{ ( z , y  , x)        → (f *′) ( y , z  , x)        }
\end{code}


\subsection{Example}
\begin{comment}
\begin{code}
module Prelude where
  open import Data.Product                          public using (_,_)
  open import Relation.Binary.PropositionalEquality public using (refl; _≡_)
\end{code}
\end{comment}
We will need some language to describe natural language semantics.
Agda has a built-in type for Booleans, but we are not really
interested in computing anything, so we will simply postulate
everything:
\\[1\baselineskip]
\begin{code}
  postulate
    Entity  : Set
    Bool    : Set
    exists  : {a : Set} → (a → Bool) → Bool
    forAll  : {a : Set} → (a → Bool) → Bool
    _⊃_     : Bool → Bool → Bool
    _∧_     : Bool → Bool → Bool
\end{code}
\\
We define the atomic types, their translation to Agda types, and a
concept of polarity:
\\[1\baselineskip]
\begin{code}
  data Atom : Set where S N NP : Atom
\end{code}
\\
The translation function then follows, and with it we can instantiate
the syntax and semantics modules:
\\[1\baselineskip]
\begin{code}
  instance
    TranslateAtom : Translate Atom Set
    TranslateAtom = record { _* = _*′ }
      where
        _*′  : Atom → Set
        S   *′ = Bool
        N   *′ = Entity → Bool
        NP  *′ = Entity
\end{code}
\begin{comment}
\begin{code}
module Example1 where
  open Prelude
\end{code}
\end{comment}
\begin{code}
  PolarisedAtom : Polarised Atom
  PolarisedAtom = record { Pol = λ _ → - }
\end{code}
\begin{comment}
\begin{code}
  open Syntax     Atom PolarisedAtom
  open Semantics  Atom PolarisedAtom TranslateAtom
\end{code}
\end{comment}
\\
Then we define the syntactic types for our example sentence. There are
much better ways to do this---building a lexicon, computing the
sequent from the given words, etc---and many of these are used in the
Haskell implementation, but since the Agda version lacks proof search,
there is no real reason to invest in all this machinery:
\\[1\baselineskip]
\begin{code}
  MARY SEES FOXES : Struct +
  MARY   = · El NP ·
  SEES   = · (El NP ⇒ El S) ⇐ El NP ·
  FOXES  = · QW((El S ⇦ El NP) ⇨ El S) ·
\end{code}
\\
A proof for this sentence is easily given:
\\[1\baselineskip]
\begin{code}
  syn0  : NLQ MARY ∙ SEES ∙ FOXES ⊢ · El S ·
  syn0  =  qL (PROD2 _ (PROD2 _ HOLE)) (unfR refl
        (  qR (PROD2 _ (PROD2 _ HOLE)) (resRP (resLP (focL refl
        (  impLL axR (impRL axR axL))))))) axL
\end{code}
\\
We then postulate some primitive meanings, and use these to give some
definitions for our lexical entries. The real work is done in the
definition of \AgdaFunction{foxes}:
\\[1\baselineskip]
\begin{code}
  postulate
    mary    : Entity
    see     : Entity → Entity → Bool
    fox     : Entity → Bool

  sees : SEES *
  sees y x = see x y

  foxes : FOXES *
  foxes v = exists {Entity → Bool} (λ f → forAll {Entity} (λ x → f x ⊃ (fox x ∧ v x)))
\end{code}
\\
And finally, we translate our syntactic proof, insert the lexical
entries, and normalise, et voil\`{a}! We have our semantics:
\\[1\baselineskip]
\begin{code}
  sem0  : (syn0 *) (mary , sees , foxes)
        ≡ exists (λ f → forAll (λ x → f x ⊃ (fox x ∧ see mary x)))
  sem0  = refl
\end{code}

\subsection{CPS-semantics and indefinites}
We mentioned that one possible way of dealing with indefinites is to
extend the CPS-semantics for focused NL, given earlier, to full NLQ.
This would allow us to model quantifiers using the \textbf{IBC}-rules,
but indefinites using a semantic CPS-translation. In order to do this,
we are going to define the CPS-semantics for NLQ. We abstract in our
module header, much like we did for our \AgdaModule{Semantics} module:
\\[1\baselineskip]
\begin{code}
module CPS-Semantics
  (Atom : Set) (R : Set)
  (PolarisedAtom   : Polarised Atom)
  (TranslateAtom   : Translate Atom Set)
  where
\end{code}
\begin{comment}
\begin{code}
  open import Data.Unit    using (⊤; tt)
  open import Data.Product using (_×_; _,_)
  open import Relation.Binary.PropositionalEquality using (_≡_; refl)
  open Syntax Atom PolarisedAtom

  infixl 1 _ᴿ
\end{code}
\end{comment}
\begin{comment}
\begin{code}
  private instance PolarisedAtomInst = PolarisedAtom
  private instance TranslateAtomInst = TranslateAtom
\end{code}
\end{comment}
\\
And we define some convenient syntax for continuation types:
\\[1\baselineskip]
\begin{code}
  _ᴿ : Set → Set
  a ᴿ = a → R
\end{code}
\\
The most complex part of the CPS-translation is the polarity-driven
translation on types, formalised below:
\\[1\baselineskip]
\begin{code}
  ⟦_⟧_ : Type → Polarity → Set
  ⟦  El      a    ⟧ + with Pol(a)
  ⟦  El      a    ⟧ + | +  = a *
  ⟦  El      a    ⟧ + | -  = a * ᴿ ᴿ
  ⟦  Dia   k a    ⟧ +      = ⟦ a ⟧ +
  ⟦  Box   k a    ⟧ +      = ⟦ a ⟧ - ᴿ
  ⟦  UnitL k a    ⟧ +      = ⟦ a ⟧ +
  ⟦  ImpR  k a b  ⟧ +      = ⟦ a ⟧ + × ⟦ b ⟧ - ᴿ
  ⟦  ImpL  k b a  ⟧ +      = ⟦ b ⟧ - × ⟦ a ⟧ + ᴿ
  ⟦  El      a    ⟧ -      = a * ᴿ
  ⟦  Dia   k a    ⟧ -      = ⟦ a ⟧ + ᴿ
  ⟦  Box   k a    ⟧ -      = ⟦ a ⟧ -
  ⟦  UnitL k a    ⟧ -      = ⟦ a ⟧ + ᴿ
  ⟦  ImpR  k a b  ⟧ -      = ⟦ a ⟧ + × ⟦ b ⟧ -
  ⟦  ImpL  k b a  ⟧ -      = ⟦ b ⟧ - × ⟦ a ⟧ +
\end{code}
\\
For structures and sequents, the translations are simple, and we can
resort to using our previous \AgdaFunction{Translate} class. As
mentioned, we simply translate \emph{all} structural connectives as
products:
\\[1\baselineskip]
\begin{code}
  instance
    TranslateStruct : ∀ {p} → Translate (Struct p) Set
    TranslateStruct {p} = record { _* = _*′ }
      where
      _*′ : ∀ {p} → Struct p → Set
      _*′ {p} · a · = ⟦ a ⟧ p
      B            *′ = ⊤
      C            *′ = ⊤
      I*           *′ = ⊤
      DIA   k x    *′ = x *′
      UNIT  k      *′ = ⊤
      PROD  k x y  *′ = x *′ × y *′
      BOX   k x    *′ = x *′
      IMPR  k x y  *′ = x *′ × y *′
      IMPL  k y x  *′ = y *′ × x *′
\end{code}
\\
And we translate sequents as Agda functions:
\\[1\baselineskip]
\begin{code}
  instance
    TranslateSequent : Translate Sequent Set
    TranslateSequent = record { _* = _*′ }
      where
      _*′ : Sequent → Set
      (  x  ⊢  y  ) *′ = x * → y * → R
      ([ a ]⊢  y  ) *′ = y * → ⟦ a ⟧ -
      (  x  ⊢[ b ]) *′ = x * → ⟦ b ⟧ +
\end{code}
\\
The final part is the translation on proofs. Before we give the full
translation on proofs, we will demonstrate that for all \AgdaBound{a},
if there is a clash in polarity between the polarity of a type and the
polarity of the translation, we obtain a ``continuation type''
\AgdaBound{a} \AgdaFunction{ᴿ}:
\\[1\baselineskip]
\begin{code}
  lem-⟦·⟧ : ∀ {p} (a : Type) → Pol(a) ≡ p → (⟦ a ⟧ ~ p) ≡ (⟦ a ⟧ p ᴿ)
  lem-⟦·⟧ { + } ( El       a    ) pr rewrite pr = refl
  lem-⟦·⟧ { - } ( El       a    ) pr rewrite pr = refl
  lem-⟦·⟧ { + } ( Dia    k a    ) pr = refl
  lem-⟦·⟧ { - } ( Dia    k a    ) ()
  lem-⟦·⟧ { + } ( Box    k a    ) ()
  lem-⟦·⟧ { - } ( Box    k a    ) pr = refl
  lem-⟦·⟧ { + } ( UnitL  k a    ) pr = refl
  lem-⟦·⟧ { - } ( UnitL  k a    ) ()
  lem-⟦·⟧ { + } ( ImpR   k a b  ) ()
  lem-⟦·⟧ { - } ( ImpR   k a b  ) pr = refl
  lem-⟦·⟧ { + } ( ImpL   k a b  ) ()
  lem-⟦·⟧ { - } ( ImpL   k a b  ) pr = refl
\end{code}
\\
All rules translate to
permutations on product types, insert units or map functions over
product types. The actual applications and abstractions are hiding in
\AgdaFunction{unfR}, \AgdaFunction{unfL}, \AgdaFunction{focR} and
\AgdaFunction{focL}, which correspond to the translations of the rules
of the same name given earlier:
\\[1\baselineskip]
\begin{code}
  instance
    TranslateProof : ∀ {s} → Translate (NLQ s) (s *)
    TranslateProof = record { _* = _*′ }
      where
      _*′ : ∀ {s} → NLQ s → s *
      axElR _        *′ = λ x → x
      axElL _        *′ = λ x → x
      unfR  {b = b} n  f  *′ rewrite lem-⟦·⟧ b n = λ x y → (f *′) x y
      unfL  {a = a} p  f  *′ rewrite lem-⟦·⟧ a p = λ y x → (f *′) x y
      focR  {b = b} p  f  *′ rewrite lem-⟦·⟧ b p = λ x k → k ((f *′) x)
      focL  {a = a} n  f  *′ rewrite lem-⟦·⟧ a n = λ k x → k ((f *′) x)
      impRL     f g  *′ = λ{(x , y) → ((f *′) x , (g *′) y)}
      impRR     f    *′ = (f *′)
      impLL     f g  *′ = λ{(x , y) → ((g *′) x , (f *′) y)}
      impLR     f    *′ = (f *′)
      resRP     f    *′ = λ{(x , y) z → (f *′) y (x , z)}
      resPR     f    *′ = λ{y (x , z) → (f *′) (x , y) z}
      resLP     f    *′ = λ{(x , y) z → (f *′) x (z , y)}
      resPL     f    *′ = λ{x (z , y) → (f *′) (x , y) z}
      diaL      f    *′ = f *′
      diaR      f    *′ = f *′
      boxL      f    *′ = f *′
      boxR      f    *′ = f *′
      resBD     f    *′ = f *′
      resDB     f    *′ = f *′
      unitLL    f    *′ = λ{ x → (f *′) (tt , x) }
      unitLR    f    *′ = λ{ (tt , x) → (f *′) x }
      unitLI    f    *′ = λ{ (tt , x) → (f *′) x }
      dnB       f    *′ = λ{ (((tt , x) , y) , z) → (f *′) (x , (y , z)) }
      upB       f    *′ = λ{ (x , (y , z)) → (f *′) (((tt , x) , y) , z) }
      dnC       f    *′ = λ{ (((tt , x) , z) , y) → (f *′) ((x , y) , z) }
      upC       f    *′ = λ{ ((x , y) , z) → (f *′) (((tt , x) , z) , y) }
      upI*      f    *′ = λ{ (x , y) → (f *′) ((tt , x) , y) }
      dnI*      f    *′ = λ{ ((tt , x) , y) → (f *′) (x , y) }
      ifxRR     f    *′ = λ{ (x , (y , z)) → (f *′) ((x , y) , z) }
      ifxLR     f    *′ = λ{ ((x , z) , y) → (f *′) ((x , y) , z) }
      ifxLL     f    *′ = λ{ ((z , y) , x) → (f *′) (z , (y , x)) }
      ifxRL     f    *′ = λ{ (y , (z , x)) → (f *′) (z , (y , x)) }
      extRR     f    *′ = λ{ ((x , y) , z) → (f *′) (x , (y , z)) }
      extLR     f    *′ = λ{ ((x , y) , z) → (f *′) ((x , z) , y) }
      extLL     f    *′ = λ{ (z , (y , x)) → (f *′) ((z , y) , x) }
      extRL     f    *′ = λ{ (z , (y , x)) → (f *′) (y , (z , x)) }
\end{code}
\begin{comment}
\begin{code}
module Example2 where
  open Prelude
  open import Function using (flip)
\end{code}
\end{comment}
\\
Once again, we demonstrate a small example. In this case, the example
sentence will be ``Everyone said some guest left''. This sentence
should have an ambiguous interpretation. We will use a CPS-translation
for the indefinite ``some'' to obtain this ambiguity, counting on the
scope ambiguity which we can obtain by setting the following
polarities in focused NL:
\\[1\baselineskip]
\begin{code}
  PolarisedAtom : Polarised Atom
  PolarisedAtom = record { Pol = Pol′ }
    where
      Pol′ : Atom → Polarity
      Pol′ S   = -
      Pol′ N   = +
      Pol′ NP  = +
\end{code}
\begin{comment}
\begin{code}
  open Syntax Atom PolarisedAtom
  open CPS-Semantics Atom Bool PolarisedAtom TranslateAtom
\end{code}
\end{comment}
\\
We then define some types for the words in our sentence: we define
``everyone'' as a syntactic quantifier, but define ``someone'' as a
semantic, CPS-translated quantifier:
\\[1\baselineskip]
\begin{code}
  EVERYONE  : Struct +
  EVERYONE  = · QW((El S ⇦ El NP) ⇨ El S) ·
  SAID      : Struct +
  SAID      = · (El NP ⇒ El S) ⇐ (◇ El S) ·
  SOME      : Struct +
  SOME      = · El NP ⇐ El N ·
  GUEST     : Struct +
  GUEST     = · El N ·
  LEFT      : Struct +
  LEFT      = · El NP ⇒ El S ·
\end{code}
\\
The result is that, while ``some'' cannot escape the scope island
through syntactic movement, it nonetheless takes scope, through the
CPS-translation. And, because of our chosen polarisation, there are
three different derivations: in \AgdaFunction{syn1a}, we start by
collapsing ``some guest'', then let ``everyone'' take scope, and only
then collapse the sentence scope and resolve the embedded clause; in
\AgdaFunction{syn1b}, we start by letting ``everyone''' take scope,
then we collapse ``some guest''', and again end by collapsing the
sentence scope and resolving the embedded clause; and, in
\AgdaFunction{syn1c}, we again start by letting ``everyone'' take
scope, but this time we collapse the sentence scope, and move to the
embedded clause, \emph{before} we collapse ``some person''.
\\[1\baselineskip]
\begin{code}
  syn1a  : NLQ EVERYONE ∙ SAID ∙ ⟨ ( SOME ∙ GUEST ) ∙ LEFT ⟩ ⊢ · El S ·
  syn1a  =  (dp2 ((_ ∙> (_ ∙> (◆> ((HOLE <∙ _) <∙ _)))) <⊢ _)
            (focL refl (impLL axR (unfL refl
            (dp1 ((_ ∙> (_ ∙> (◆> (HOLE <∙ _)))) <⊢ _)
            (flip (q (PROD1 HOLE _)) axL
            (dp2 ((_ ∙> (HOLE <∙ _)) <⊢ _)
            (focL refl (impLL (diaR (unfR refl (resRP (focL refl axL)))) axL
            )))))))))

  syn1b  : NLQ EVERYONE ∙ SAID ∙ ⟨ ( SOME ∙ GUEST ) ∙ LEFT ⟩ ⊢ · El S ·
  syn1b  =  (flip (q (PROD1 HOLE _)) axL
            (dp2 ((_ ∙> (_ ∙> (◆> ((HOLE <∙ _) <∙ _)))) <⊢ _)
            (focL refl (impLL axR (unfL refl
            (dp1 ((_ ∙> (_ ∙> (◆> (HOLE <∙ _)))) <⊢ _)
            (dp2 ((_ ∙> (HOLE <∙ _)) <⊢ _)
            (focL refl (impLL (diaR (unfR refl (resRP (focL refl axL)))) axL
            )))))))))

  syn1c  : NLQ EVERYONE ∙ SAID ∙ ⟨ ( SOME ∙ GUEST ) ∙ LEFT ⟩ ⊢ · El S ·
  syn1c  =  (flip (q (PROD1 HOLE _)) axL
            (dp2 ((_ ∙> (HOLE <∙ _)) <⊢ _)
            (focL refl (flip impLL axL (diaR (unfR refl
            (dp2 (((HOLE <∙ _) <∙ _) <⊢ _)
            (focL refl (impLL axR (unfL refl (resPL (resRP (focL refl axL)
            ))))))))))))
\end{code}
\\
In order to assign an interpretation to our derivations, we give some
definitions for our lexical terms. These are now slightly more
complicated, using the CPS-translated types:
\\[1\baselineskip]
\begin{code}
  postulate
    person  : Entity → Bool
    guest   : Entity → Bool
    say     : Entity → Bool → Bool
    leave   : Entity → Bool

  everyone             : EVERYONE *
  everyone (f , k)     = forAll (λ x → person x ⊃ (f (k , x)))
  said                 : SAID *
  said ((x , k) , k')  = k (say x (k' (λ y → y)))
  some                 : SOME *
  some (k , f)         = exists (λ x → f x ∧ k x)
  left                 : LEFT *
  left (x , k)         = k (leave x)
\end{code}
\\
And, when we compute our meanings---inserting the identity function in
order to extract a meaning out of the continuation---we see that we
get exactly the desired result:
\\[1\baselineskip]
\begin{code}
  sem1a  : (syn1a *) (everyone , said , (some , guest) , left) (λ x → x)
         ≡ exists (λ y → guest y ∧ forAll (λ x → person x ⊃ say x (leave y)))
  sem1a  = refl
  sem1b  : (syn1b *) (everyone , said , (some , guest) , left) (λ x → x)
         ≡ forAll (λ x → person x ⊃ exists (λ y → guest y ∧ say x (leave y)))
  sem1b  = refl
  sem1c  : (syn1c *) (everyone , said , (some , guest) , left) (λ x → x)
         ≡ forAll (λ x → person x ⊃ (say x (exists (λ y → guest y ∧ leave y))))
  sem1c  = refl
\end{code}
\end{appendices}
\end{document}
