# PsyEmbedR 0.1.1

- Improved diagnostics for `definitions` validation by clarifying the
  expected named-character-vector structure.
- Hardened `ensure_python_deps()` so it creates the parent directory of
  the virtualenv root before calling `reticulate::virtualenv_create()`,
  which avoids first-run failures on some fresh Windows and Conda-based
  setups.
- Made embedding extraction more robust for single-item inputs across
  different `reticulate` / Python conversions by forcing Python list
  input and coercing one-dimensional embedding arrays to a `1 x d`
  matrix in R.

# PsyEmbedR 0.1.0

- Initial release.
- Added local integration with Python via `reticulate` and
  `sentence-transformers`.
- Added semantic embedding, cosine similarity, alignment, redundancy,
  and semantic coverage reporting utilities.
- Added tests, vignette, README, and citation metadata.
- Improved error handling when `reticulate` has already initialized a
  different Python interpreter in the active R session.
- Added fallback behavior to reuse the active Python interpreter in the
  current R session when switching to the dedicated virtual environment
  is no longer possible.
- Added `detect_text_language()` and `infer_dimensions()`.
- Added support for `model_name = "auto"` to select an English or
  multilingual sentence-transformers model heuristically from the input
  texts.
- Added `plot_semantic_map()` for two-dimensional semantic
  visualization of items.
- Replaced the single workflow script with separate Spanish and English
  example scripts.
- Added threshold-based handling for weak semantic assignments in
  `infer_dimensions()` and `semantic_coverage_report()`.
- Made `plot_semantic_map()` more robust by using standard text labels by
  default and leaving `ggrepel` as an explicit option.
