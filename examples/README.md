# CIMTOOL — Feature Examples (branch `cleanup/prelim-hardening`)

Runnable, narrated demos of the changes on this branch. Each script is
self-contained (uses a synthetic 6-pole transfer function — **no NLEVP install
required**), prints what it is showing, and asserts the new behavior so you can
*see* the change and confirm nothing regressed.

## Run everything

From the repo root in MATLAB:

```matlab
addpath(genpath("src"))
cd examples
run_all_examples      % runs the 5 demos below, then the full headless test suite
```

Or run any one on its own (after `addpath(genpath("src"))`):

| Script | Shows | Maps to |
|---|---|---|
| `example1_optimal_matching.m`   | Greedy → **optimal** matching distance (greedy over-reports) | PROGRESS §4 |
| `example2_crossmode_tf.m`       | All 3 modes now reconstruct **+H(z)** (SPLoewner sign fix B2) | PROGRESS §1 |
| `example3_mploewner_rectangular.m` | MPLoewner with **unequal #θ/#σ** works; too-few-points errors loudly | PROGRESS §7 |
| `example4_input_validation.m`   | Bad constructor/property inputs rejected with **clear errors** | PROGRESS §8 |
| `example5_modal_truncation.m`   | `Visual.ModalTruncation` **constructs** (B5) + clean H = H_region + H_residual | PROGRESS §1 |

## "Nothing else broke" check

The authoritative regression check is the headless numerics suite:

```matlab
cd tests
run_numerics_tests    % 10 tests, isolated workspaces, errors on any failure
```

`run_all_examples` calls this for you at the end.
