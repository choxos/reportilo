# reportilo Shiny application (placeholder).
#
# This minimal app is replaced by the full modular application in the
# feature/shiny-app pull request. It is kept here so that launch_reportilo()
# resolves to a runnable app from the first release of the package skeleton.

library(shiny)
library(bslib)

ui <- page_fluid(
  theme = bs_theme(version = 5),
  title = "reportilo",
  card(
    card_header("reportilo"),
    card_body(
      p(
        "Fill in and export EQUATOR reporting guidelines and flow diagrams."
      ),
      p(
        "The full application is under construction. In the meantime, use the",
        "package functions directly from R."
      )
    )
  )
)

server <- function(input, output, session) {
}

shinyApp(ui, server)
