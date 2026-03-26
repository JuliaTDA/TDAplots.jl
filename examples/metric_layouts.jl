# Metric Layouts Example
#
# By default, mapper_plot uses a force-directed graph layout (Spring).
# Metric layouts instead position nodes based on the geometry of the
# underlying data — using the centroids of each cover element and
# applying dimensionality reduction (MDS, t-SNE, Isomap, etc.).

using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate 2000 points on a torus
X = torus(2000)

# Use z-coordinate as filter function
fv = [p[3] for p in X]

# Build classical mapper
ic = R1Cover(fv, Uniform(length=15, expansion=0.3))
M = classical_mapper(X, ic, DBscan(radius=0.3))

# --- Spring layout (default, graph-based) ---
fig1 = mapper_plot(M)

# --- MDS layout (metric-based) ---
pos_mds = layout_mds(M, dim=2)
fig2 = mapper_plot(M, node_positions=pos_mds, node_values=node_colors(M, fv))

# --- Isomap layout ---
pos_isomap = layout_isomap(M, dim=2)
fig3 = mapper_plot(M, node_positions=pos_isomap, node_values=node_colors(M, fv))

# --- 3D MDS layout ---
pos_3d = layout_mds(M, dim=3)
fig4 = mapper_plot(M, node_positions=pos_3d, node_values=node_colors(M, fv))
