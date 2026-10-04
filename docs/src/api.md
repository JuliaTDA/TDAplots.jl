# API reference

This page documents the symbols defined by `TDAplots.jl`. `using TDAplots` also
re-exports the full `TDAmapper` and `MetricSpaces` APIs; see those packages'
documentation for their symbols.

| Purpose | Main entry points | Guide |
| :--- | :--- | :--- |
| Observations and Mapper | `metricspace_plot`, `mapper_plot`, `node_colors` | [Mapper tutorial](mapper.md) |
| Linked selection | `mapper_explorer`, `MapperExplorer` | [Select a node](mapper.md#Select-a-node-and-examine-its-members) |
| Graph/centroid embeddings | `centroid`, `layout_generic`, `layout_*` | [Layouts](layouts.md) |
| Homology intervals | `persistence_plot`, `barcode_plot` | [Persistence](persistence.md) |
| Density-mode clustering | `tomato_graph_plot`, `tomato_persistence_plot` | [ToMATo views](persistence.md#ToMATo:-a-valley-connects-density-peaks) |
| Scaling utilities | `rescale`, `colorscale` | [Practical guide](practical.md) |

```@meta
CurrentModule = TDAplots
```

```@index
```

```@autodocs
Modules = [TDAplots]
```
