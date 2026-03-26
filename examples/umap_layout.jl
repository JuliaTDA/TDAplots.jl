# UMAP Layout Example
#
# UMAP (Uniform Manifold Approximation and Projection) is a popular
# nonlinear dimensionality reduction method that preserves both local
# and global structure. It often produces more meaningful layouts than
# t-SNE for topological data.

using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate 5000 points on a torus
X = torus(5000)

# Use y-coordinate as filter function
fv = [p[2] for p in X]

# Build classical mapper
ic = R1Cover(fv, Uniform(length=15, expansion=0.5))
M = classical_mapper(X, ic, DBscan(radius=0.2))

# --- 2D UMAP layout ---
pos_2d = layout_umap(M, dim=2)
fig1 = mapper_plot(M, node_positions=pos_2d, node_values=node_colors(M, fv))

# --- 3D UMAP layout ---
pos_3d = layout_umap(M, dim=3)
fig2 = mapper_plot(M, node_positions=pos_3d, node_values=node_colors(M, fv))
