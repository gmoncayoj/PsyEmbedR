# Full PsyEmbedR workflow example in Spanish

library(PsyEmbedR)

items <- c(
  "Me recupero rapidamente despues de una situacion dificil.",
  "Puedo adaptarme cuando las circunstancias cambian.",
  "Siento que mi familia me brinda apoyo cuando lo necesito.",
  "Las personas cercanas a mi me ayudan a enfrentar los problemas.",
  "Ajusto mi conducta cuando aparecen nuevas exigencias.",
  "Cuento con apoyo social para afrontar momentos estresantes."
)

definitions <- c(
  adaptive = "Capacidad de ajustarse flexiblemente a cambios, exigencias o adversidad.",
  ecological = "Recursos contextuales, familiares y sociales que favorecen el afrontamiento."
)

expected_dimension <- c(
  "adaptive",
  "adaptive",
  "ecological",
  "ecological",
  "adaptive",
  "ecological"
)

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
print(alignment)

# 6. Infer the most likely dimension for each item.
# Items below the minimum similarity threshold are labeled
# "no clear alignment" rather than being forced into a dimension.
predicted_dimensions <- infer_dimensions(
  items = items,
  definitions = definitions
)
print(predicted_dimensions)

# 7. Plot the two-dimensional semantic map.
# The default MDS projection is based on cosine distance, so it reflects
# the item-to-item similarity structure directly.
semantic_map <- plot_semantic_map(items)
print(semantic_map)

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
