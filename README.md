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

items <- c("I have a good sense of why I have certain feelings most of the time",
           "I have good understanding of my own emotions",
           "I really understand what I feel",
           "I always know whether or not I am happy",
           "I always know my friends’ emotions from their behaviour",
           "I am a good observer of others’ emotions",
           "I am sensitive to the feelings and emotions of others",
           "I have good understanding of the emotions of people around me",
           "I always set goals for myself and then try my best to achieve them",
           "I always tell myself I am a competent person",
           "I am a self-motivating person",
           "I would always encourage myself to try my best",
           "I am able to control my temper so that I can handle difficulties rationally",
           "I am quite capable of controlling my own emotions",
           "I can always calm down quickly when I am very angry",
           "I have good control of my own emotions"
)

definitions <- c(
  SEA = "Individual’s ability to understand their deep emotions and be able to express these emotions naturally",
  #Self Emotional Appraisal
  OEA = "People's ability to perceive and understand the emotions of those people around them",
  #Others' Emotional Appraisal
  UOE = "Ability of individuals to make use of their emotions by directing them towards constructive activities and personal performance",
  #Use of Emotion
  ROE = "Ability of people to regulate their emotions, which will enable a more rapid recovery from psychological distress"
  #Regulation of Emotion
)

# Sort the items according to the dimension they belong to, in the same order as specified in the “items” object
expected_dimension <- c("SEA", "SEA", "SEA", "SEA",
                        "OEA", "OEA", "OEA", "OEA",
                        "UOE", "UOE", "UOE", "UOE",
                        "ROE", "ROE", "ROE", "ROE")


# 1. Prepare Python dependencies before any semantic analysis.
deps <- ensure_python_deps()
print(deps)

# 2. Detect the dominant language from items and definitions.
# This helps confirm the automatic model choice.
language <- detect_text_language(c(items, unname(definitions)))
print(language)

# 3. Generate item embeddings.
# Each row represents one item in the semantic vector space.
embeddings <- embed_items(items)
print(dim(embeddings))

# 4. Compute item-to-item cosine similarity.
# Higher values indicate stronger semantic proximity.
item_similarity <- cosine_matrix(embeddings)
print(round(item_similarity, 3))

# 5. Align items to theoretical definitions.
# This returns the full item-definition similarity table.
alignment <- align_to_definition(
  items = items,
  definitions = definitions
)
print(alignment, n = Inf, width = Inf)

# 6. Infer the most likely dimension for each item.
# Items below the minimum similarity threshold are labeled
# "no clear alignment" rather than being forced into a dimension.
predicted_dimensions <- infer_dimensions(
  items = items,
  definitions = definitions
)
print(predicted_dimensions, n = Inf, width = Inf)

# 7. Plot the two-dimensional semantic map.
# The default MDS projection is based on cosine distance, so it reflects
# the item-to-item similarity structure directly.
semantic_map <- plot_semantic_map(items)
print(semantic_map, n = Inf, width = Inf)

# 7a. Color the map by inferred semantic dimension.
# Projection method and color strategy are independent choices.
semantic_map_inferred <- plot_semantic_map(
  items = items,
  definitions = definitions,
  color_by = "inferred"
)
print(semantic_map_inferred)

# 7b. Color the map by expected dimension while using PCA coordinates.
semantic_map_expected <- plot_semantic_map(
  items = items,
  expected_dimension = expected_dimension,
  method = "pca",
  color_by = "expected"
)
print(semantic_map_expected)

# If you prefer, you can also force label behavior explicitly:
# semantic_map <- plot_semantic_map(items, label_method = "repel")
# semantic_map <- plot_semantic_map(items, label_method = "text")
# semantic_map <- plot_semantic_map(items, label_method = "none")

# 8. Flag potentially redundant item pairs.
# Review these pairs for possible semantic overlap.
redundant_pairs <- flag_redundancy(
  items = items,
  threshold = 0.80
)
print(redundant_pairs)

# 9. Summarize semantic coverage.
# This combines inferred semantic classification with the expected
# theoretical dimension assigned by the analyst.
coverage <- semantic_coverage_report(
  items = items,
  definitions = definitions,
  expected_dimension = expected_dimension
)

print(coverage$best_alignment)
print(coverage$summary_by_dimension)
print(coverage$classification_summary)
print(coverage$misaligned_items)
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
