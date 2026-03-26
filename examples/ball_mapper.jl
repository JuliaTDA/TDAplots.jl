# Ball Mapper Example
#
# Ball Mapper uses landmark points and fixed-radius balls
# instead of a filter function. It captures the shape of
# the data directly in the domain.

using TDAplots
using TDAmapper.Refiners

# Generate 2000 points on a torus
X = torus(2000)

# Select 100 well-spaced landmarks via farthest point sampling
L = farthest_points_sample_ids(X, 100)

# Build ball mapper with radius 0.8
M = ball_mapper(X, L, 0.8)

# Visualize, coloring by height (z-coordinate)
z_values = [p[3] for p in X]
fig = mapper_plot(M, node_values=node_colors(M, z_values))

# Categorical coloring: label points by hemisphere
labels = [p[3] > 0 ? "upper" : "lower" for p in X]
fig2 = mapper_plot(M, node_values=node_colors(M, labels))
