using TDAplots

X = sphere(500; dim=3)

# Basic plot (first 3 dims)
metricspace_plot(X)

# With numeric colorscale
metricspace_plot(X; color=first.(X))

# With categorical labels
labels = [x[3] > 0 ? "top" : "bottom" for x in X]
metricspace_plot(X; color=labels)

# Pick specific dimensions from high-dimensional data
X5 = cube(500; dim=5)
metricspace_plot(X5; dims=[1, 3, 5])

# 2D plot
metricspace_plot(X5; dims=[2, 4])
