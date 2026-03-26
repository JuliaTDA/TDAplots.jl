# Graph-Topology Layouts Example
#
# These layouts position nodes based on the mapper graph structure
# (edges and connectivity) rather than the geometry of the point cloud.
# They use NetworkLayout algorithms under the hood, but return Point
# vectors compatible with mapper_plot's node_positions argument.

using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate 5000 points on a torus
X = torus(5000)

# Use y-coordinate as filter function
fv = [p[2] for p in X]

# Build classical mapper
ic = R1Cover(fv, Uniform(length=15, expansion=0.5))
M = classical_mapper(X, ic, DBscan(radius=0.2))

colors = node_colors(M, fv)

# --- Spring (force-directed) layout ---
pos_spring = layout_spring(M, dim=2)
fig1 = mapper_plot(M, node_positions=pos_spring, node_values=colors)

# --- Stress majorization layout ---
pos_stress = layout_stress(M, dim=2)
fig2 = mapper_plot(M, node_positions=pos_stress, node_values=colors)

# --- Spectral graph layout ---
pos_spectral = layout_spectral_graph(M, dim=2)
fig3 = mapper_plot(M, node_positions=pos_spectral, node_values=colors)

# --- SFDP layout ---
pos_sfdp = layout_sfdp(M, dim=2)
fig4 = mapper_plot(M, node_positions=pos_sfdp, node_values=colors)

# --- Shell layout (always 2D) ---
pos_shell = layout_shell(M)
fig5 = mapper_plot(M, node_positions=pos_shell, node_values=colors)

# --- 3D Spring layout ---
pos_3d = layout_spring(M, dim=3)
fig6 = mapper_plot(M, node_positions=pos_3d, node_values=colors)
