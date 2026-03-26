# Basic Classical Mapper Example
#
# This example shows the simplest end-to-end workflow:
# 1. Generate a point cloud on a circle
# 2. Run the classical mapper algorithm
# 3. Visualize the result

using TDAplots
using TDAmapper.ImageCovers, TDAmapper.IntervalCovers, TDAmapper.Refiners

# Generate 1000 points on a unit circle in 2D
X = sphere(1000, dim=2)

# Use the x-coordinate as a filter function
fv = first.(X)

# Create an image covering: 10 overlapping intervals with 30% overlap
ic = R1Cover(fv, Uniform(length=10, expansion=0.3))

# Run mapper with DBSCAN clustering (radius=0.1)
M = classical_mapper(X, ic, DBscan(radius=0.1))

# Visualize — nodes are colored by the mean x-coordinate of their points,
# and sized proportionally to how many points they contain
fig = mapper_plot(M)

# Custom coloring: use the y-coordinate instead
y_values = [p[2] for p in X]
fig2 = mapper_plot(M, node_values=node_colors(M, y_values))
