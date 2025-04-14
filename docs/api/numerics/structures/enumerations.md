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