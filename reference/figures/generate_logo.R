# Generate the reportilo hex logo.
#
# Concept: a reporting checklist (three rows with check marks) feeding a small
# downward flow diagram (two boxes joined by an arrow), the two things the
# package helps you fill in and export. Run from the package root:
#   Rscript man/figures/generate_logo.R
#
# Requires: hexSticker, ggplot2, systemfonts (and ragg/svglite for output).

suppressPackageStartupMessages({
  library(ggplot2)
  library(hexSticker)
})

ink <- "#0E3A5F" # deep blue
accent <- "#1FA37A" # teal/green (check marks, arrow)
paper <- "#F7FAFC" # near-white
border <- "#0E3A5F"

# --- subplot: checklist rows + a tiny flow diagram -------------------------
rows <- data.frame(
  y = c(3, 2.4, 1.8),
  xmin = 1.2,
  xmax = 3.4
)

checks <- data.frame(
  x = 0.85,
  y = rows$y
)

# small flow diagram (two boxes + arrow) below the checklist
boxes <- data.frame(
  xmin = c(1.6, 1.6),
  xmax = c(3.0, 3.0),
  ymin = c(0.75, 0.05),
  ymax = c(1.15, 0.45)
)

p <- ggplot() +
  # checklist rows
  geom_segment(
    data = rows,
    aes(x = xmin, xend = xmax, y = y, yend = y),
    color = paper, linewidth = 1.6, lineend = "round"
  ) +
  # check marks (two short strokes forming a tick)
  geom_segment(
    data = checks,
    aes(x = x - 0.18, xend = x - 0.02, y = y - 0.02, yend = y - 0.18),
    color = accent, linewidth = 1.3, lineend = "round"
  ) +
  geom_segment(
    data = checks,
    aes(x = x - 0.02, xend = x + 0.28, y = y - 0.18, yend = y + 0.2),
    color = accent, linewidth = 1.3, lineend = "round"
  ) +
  # flow diagram boxes
  geom_rect(
    data = boxes,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = NA, color = paper, linewidth = 1.2
  ) +
  # connecting arrow
  geom_segment(
    aes(x = 2.3, xend = 2.3, y = 0.75, yend = 0.49),
    color = accent, linewidth = 1.2,
    arrow = arrow(length = unit(0.12, "cm"), type = "closed")
  ) +
  xlim(0.4, 3.6) +
  ylim(-0.1, 3.4) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none")

sticker(
  subplot = p,
  package = "reportilo",
  p_size = 17,
  p_y = 1.02,
  p_color = paper,
  s_x = 1.0,
  s_y = 0.78,
  s_width = 1.5,
  s_height = 1.5,
  h_fill = ink,
  h_color = accent,
  h_size = 1.4,
  filename = "man/figures/logo.png",
  dpi = 320
)

message("Wrote man/figures/logo.png")
