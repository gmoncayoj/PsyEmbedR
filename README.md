# PsyEmbedR

`PsyEmbedR` is an R package for preliminary semantic auditing of
psychometric item banks. It runs locally, integrates with Python through
`reticulate`, and uses `sentence-transformers` to:

- detect the dominant language of item banks heuristically,
- auto-select a suitable embedding model when desired,
- generate embeddings for item texts,
- compute cosine similarity matrices,
- align items to theoretical definitions,
- infer the most likely theoretical dimension for each item,
- flag semantically redundant items, and
- visualize item locations in a two-dimensional semantic map,
- summarize semantic coverage by dimension.

The package does not use external AI APIs or API keys. Inference is
performed locally once the Python environment and the selected model are
available on the machine.

## Installation

Install the package from GitHub:

```r
install.packages("remotes")
remotes::install_github("gmoncayoj/PsyEmbedR")
```

If you are working from a local source directory instead:

```r
install.packages(c(
  "reticulate",
  "tibble",
  "dplyr",
  "tidyr",
  "purrr",
  "stringr",
  "cli",
  "glue",
  "rlang",
  "ggplot2",
  "ggrepel"
))

install.packages("path/to/PsyEmbedR", repos = NULL, type = "source")
```

For local installation with `remotes`:

```r
remotes::install_local("path/to/PsyEmbedR")
```

## Python Setup

`PsyEmbedR` manages a Python virtual environment through `reticulate`.
The helper below creates the virtual environment if needed, installs the
required Python packages, activates the environment, and verifies that
`sentence_transformers` is available:

```r
library(PsyEmbedR)

ensure_python_deps()
```

Python packages installed into the virtual environment:

- `sentence-transformers`
- `torch`
- `numpy`
- `scikit-learn`

If `reticulate` has already initialized Python in the current R session,
`PsyEmbedR` will reuse that active interpreter for the current session
and attempt to install any missing dependencies there. If you want to
force the dedicated virtual environment, restart the R session and call
`ensure_python_deps()` before any other package initializes Python.

On some fresh Windows or Conda-based setups, the default virtualenv root
directory may not exist yet. `PsyEmbedR` now creates that parent
directory automatically before calling `reticulate::virtualenv_create()`.
If you still prefer to control that location explicitly, set a writable
directory before loading `reticulate`:

```r
Sys.setenv(RETICULATE_VIRTUALENV_ROOT = "C:/Users/your-user/Documents/.virtualenvs")
# or:
Sys.setenv(WORKON_HOME = "C:/Users/your-user/Documents/.virtualenvs")

library(PsyEmbedR)
ensure_python_deps()
```

## Model Notes

By default, the main semantic functions use `model_name = "auto"`.
The package applies a lightweight local language heuristic:

- English-only text: `sentence-transformers/all-mpnet-base-v2`
- Spanish, mixed, or uncertain text:
  `sentence-transformers/paraphrase-multilingual-mpnet-base-v2`

You can inspect the heuristic directly:

```r
detect_text_language(items)
```

You can also override model selection explicitly through `model_name`.
`model_name` may be `"auto"`, a sentence-transformers identifier, or a
local path. For fully offline use, point to a model already available in
the local cache or stored on disk.

## Example Workflow

```r
library(PsyEmbedR)

items <- c(
  "I adapt my plans when circumstances change.",
  "I quickly detect relevant changes in my surroundings.",
  "I recover my focus after setbacks.",
  "I adjust my actions when the task becomes more demanding."
)

definitions <- c(
  adaptive = "Flexible behavior change in response to situational demands.",
  ecological = "Detection of relevant cues in the surrounding environment.",
  resilient = "Recovery of effective functioning after challenge or stress."
)

ensure_python_deps()

detect_text_language(c(items, unname(definitions)))

embeddings <- embed_items(items)
similarity <- cosine_matrix(embeddings)

alignment <- align_to_definition(
  items = items,
  definitions = definitions
)

predicted_dimensions <- infer_dimensions(
  items = items,
  definitions = definitions
)

redundant_pairs <- flag_redundancy(
  items = items,
  threshold = 0.85
)

semantic_map <- plot_semantic_map(items)

# Color by inferred dimension. This is independent of MDS vs PCA.
semantic_map_inferred <- plot_semantic_map(
  items = items,
  definitions = definitions,
  color_by = "inferred"
)

# Color by expected dimension while keeping a PCA projection.
semantic_map_expected <- plot_semantic_map(
  items = items,
  expected_dimension = c("adaptive", "ecological", "resilient", "adaptive"),
  method = "pca",
  color_by = "expected"
)

coverage <- semantic_coverage_report(
  items = items,
  definitions = definitions,
  expected_dimension = c("adaptive", "ecological", "resilient", "adaptive")
)
```

`infer_dimensions()` uses a configurable minimum similarity threshold to
avoid forcing a semantic assignment when the best match is too weak. By
default, items below `min_similarity = 0.20` are labeled
`"no clear alignment"`.

In that output, `nearest_definition` keeps the raw closest theoretical
definition, while `predicted_dimension` reflects the threshold-aware
preliminary assignment shown to the user.

`plot_semantic_map()` separates two ideas:

- `method = "mds"` or `method = "pca"` controls the 2D projection.
- `color_by = "none"`, `"inferred"`, or `"expected"` controls point colors.

## Troubleshooting

If another machine fails during `ensure_python_deps()` while creating the
virtual environment, the most common causes are:

- the virtualenv root directory does not exist yet,
- Python was already initialized by another package in the same R session,
- the selected Python installation does not have permission to write in
  the default environment location, or
- the transformer model has not been downloaded locally yet.

Recommended sequence on a new machine:

1. Start a fresh R session.
2. Run `library(PsyEmbedR)`.
3. Run `ensure_python_deps()` before any other package that may touch Python.
4. If needed, set `RETICULATE_VIRTUALENV_ROOT` to a writable folder first.

If the package will be used offline, make sure the required
sentence-transformers model is already cached locally or provide a local
model path through `model_name`.

## Exported Functions

- `ensure_python_deps()`
- `detect_text_language()`
- `embed_items()`
- `cosine_matrix()`
- `align_to_definition()`
- `infer_dimensions()`
- `flag_redundancy()`
- `plot_semantic_map()`
- `semantic_coverage_report()`

## Development Notes

The package is designed to be compatible with `devtools::check()`. Since
semantic embedding depends on a local Python environment, examples that
require Python are wrapped in `\\dontrun{}` in the function
documentation.

Complete runnable example scripts are included at:

- `inst/examples/workflow_spanish.R`
- `inst/examples/workflow_english.R`
