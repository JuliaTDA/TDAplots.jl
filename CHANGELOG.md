# Changelog

## Unreleased — independent JuliaTDA forks (3 October 2026)

* Switch persistence dependencies and imports to TDAPersistenceDiagrams with independent UUIDs and version series.


Notable changes to TDAplots are recorded here.

## Unreleased

- Prepare the package for its first General registry release.
- Add the missing MetricSpaces compatibility bound and Aqua quality checks.
- Remove the development-only sibling path for the ToMATo test dependency so
  registry and isolated test environments resolve correctly.
- Replace the overly broad `MapperExplorer` MIME display method with an
  unambiguous plain-text method; graphical display still delegates to its figure.
- Use UMAP 0.1.11, the branch compatible with Julia 1.9 and 1.10; UMAP 0.2
  declares Julia 1.10 support but currently uses Julia 1.11 syntax.
- Add Mapper, metric-space, persistence-diagram, and ToMATo visualizations,
  including the interactive Mapper explorer.
