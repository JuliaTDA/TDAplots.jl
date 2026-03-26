# PCA-Family Layouts Example
#
# Demonstrates layouts based on linear dimensionality reduction
# from MultivariateStats: PCA, KernelPCA, PPCA, Factor Analysis, and ICA.

using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate 5000 points on a torus
X = torus(5000)

# Use y-coordinate as filter function
fv = [p[3] for p in X]

# Build classical mapper
ic = R1Cover(fv, Uniform(length=15, expansion=0.5))
M = classical_mapper(X, ic, DBscan(radius=0.25))

# --- PCA layout ---
pos_pca = layout_pca(M, dim=2)
fig1 = mapper_plot(M, node_positions=pos_pca, node_values=node_colors(M, fv))

pos_pca = layout_pca(M, dim=3)
fig1 = mapper_plot(M, node_positions=pos_pca, node_values=node_colors(M, fv))


# --- Kernel PCA layout ---
pos_kpca = layout_kpca(M, dim=2)
fig2 = mapper_plot(M, node_positions=pos_kpca, node_values=node_colors(M, fv))

# --- Probabilistic PCA layout ---
pos_ppca = layout_ppca(M, dim=2)
fig3 = mapper_plot(M, node_positions=pos_ppca, node_values=node_colors(M, fv))

# --- Factor Analysis layout ---
pos_fa = layout_fa(M, dim=2)
fig4 = mapper_plot(M, node_positions=pos_fa, node_values=node_colors(M, fv))

# --- ICA layout ---
pos_ica = layout_ica(M, dim=2)
fig5 = mapper_plot(M, node_positions=pos_ica, node_values=node_colors(M, fv))
