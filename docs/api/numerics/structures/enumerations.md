# Enumerations

::: +Numerics.ComputationalMode
    options:
        show_root_heading: true

- **Hankel**: Essentially Probed Eigenvalue Realization Algorithm (ERA).
- **SPLoewner**: Hankel using probed generalized moments at a single shift.
- **MPLoewner**: Generic tangential Loewner interpolation.

---

::: +Numerics.SampleMode
    options:
        show_root_heading: true

- **Direct**: Sampling the operator via numerical integration directly.
- **Inverse**: Sampling the operator via numerical integration of the operator inverse -- in this the operator is (implicitly) assumed to satisfy the assumptions of Kelysh's theorem within the contour of interest.

---

::: +Numerics.RankRule
    options:
        show_root_heading: true

The rule applies when `RealizationData.AutoRank` is true; otherwise m is `RealizationSize.m`.

- **Tolerance**: Realize at the numerical rank of the base data matrix under `options.AbsTol` and `options.RelTol` (`Numerics.rankdet`).
- **Gap**: Realize at the largest gap in the singular values of the base data matrix (`Numerics.rankgap`), however small, and record its ratio \( \sigma_m/\sigma_{m+1} \) in `ResultData.GapRatio`.
  A ratio below `options.GapMin` is a weak gap, which warns under `options.Verbose`.
