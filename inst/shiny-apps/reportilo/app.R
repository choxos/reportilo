# reportilo Shiny application.
#
# A modern bslib + Shiny modules front end to the reportilo package: browse the
# EQUATOR guideline catalog, fill in reporting checklists and flow diagrams, and
# download them as Word, Excel or image files. Launch with
# reportilo::launch_reportilo().

library(shiny)
library(bslib)

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

theme <- bs_theme(
  version = 5,
  primary = "#0E3A5F",
  secondary = "#1FA37A",
  base_font = font_google("Inter", local = FALSE),
  heading_font = font_google("Poppins", local = FALSE)
)

guidelines <- reportilo::reportilo_guidelines()
checklist_guidelines <- guidelines[guidelines$has_checklist, , drop = FALSE]
checklist_choices <- stats::setNames(
  checklist_guidelines$guideline_id,
  paste0(
    ifelse(is.na(checklist_guidelines$acronym), checklist_guidelines$guideline_id, checklist_guidelines$acronym),
    " - ", substr(checklist_guidelines$title, 1, 70)
  )
)
study_designs <- sort(unique(stats::na.omit(guidelines$study_design)))
templates <- reportilo::flowchart_templates
template_choices <- stats::setNames(templates$template_id, templates$name)

notify_export <- function(expr, fmt) {
  tryCatch(expr, error = function(e) {
    showNotification(
      paste0("Could not export ", fmt, ": ", conditionMessage(e)),
      type = "error", duration = 8
    )
    NULL
  })
}

# ============================ Catalog module ===============================
catalogUI <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      width = 320,
      textInput(ns("search"), "Search", placeholder = "acronym, title, topic..."),
      selectInput(ns("design"), "Study design", choices = c("All" = "", study_designs)),
      checkboxInput(ns("checklist_only"), "Only guidelines with a checklist", FALSE),
      helpText("Click a row to see details.")
    ),
    DT::DTOutput(ns("table")),
    uiOutput(ns("detail"))
  )
}

catalogServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive({
      g <- guidelines
      if (isTRUE(input$checklist_only)) g <- g[g$has_checklist, ]
      if (nzchar(input$design)) g <- g[!is.na(g$study_design) & g$study_design == input$design, ]
      if (nzchar(input$search)) {
        hay <- tolower(paste(g$acronym, g$title, g$study_design, g$clinical_area))
        g <- g[grepl(tolower(input$search), hay, fixed = TRUE), ]
      }
      g
    })

    output$table <- DT::renderDT({
      g <- filtered()
      DT::datatable(
        data.frame(
          Acronym = g$acronym, Title = g$title, `Study design` = g$study_design,
          Checklist = ifelse(g$has_checklist, "yes", ""), check.names = FALSE
        ),
        rownames = FALSE, selection = "single",
        options = list(pageLength = 15, scrollX = TRUE)
      )
    })

    output$detail <- renderUI({
      sel <- input$table_rows_selected
      if (is.null(sel)) {
        return(NULL)
      }
      g <- filtered()[sel, ]
      info <- reportilo::guideline_info(g$guideline_id)
      files <- info$downloadable_files
      card(
        card_header(paste0(info$acronym %||% info$guideline_id, " - ", info$title)),
        card_body(
          tags$p(tags$strong("Study design: "), info$study_design %||% "NA"),
          tags$p(tags$strong("Checklist: "), if (isTRUE(info$has_checklist)) "available (Checklists tab)" else "catalog only"),
          if (!is.na(info$flowchart_template)) tags$p(tags$strong("Flow diagram: "), info$flowchart_template),
          if (!is.na(info$equator_url %||% NA)) tags$p(tags$a(href = info$equator_url, "EQUATOR page", target = "_blank")),
          if (length(files)) {
            tags$ul(lapply(files, function(f) tags$li(tags$a(href = f$url, f$label %||% f$url, target = "_blank"))))
          }
        )
      )
    })
  })
}

# =========================== Checklist module ==============================
checklistUI <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      width = 340,
      selectInput(ns("guideline"), "Guideline", choices = checklist_choices),
      uiOutput(ns("badge")),
      helpText("Double-click a cell in the Reported column to fill it in."),
      downloadButton(ns("dl_docx"), "Word (.docx)", class = "btn-primary btn-sm"),
      downloadButton(ns("dl_xlsx"), "Excel (.xlsx)", class = "btn-secondary btn-sm"),
      downloadButton(ns("dl_csv"), "CSV", class = "btn-outline-secondary btn-sm")
    ),
    DT::DTOutput(ns("table"))
  )
}

checklistServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    rv <- reactiveValues(chk = NULL)

    observeEvent(input$guideline,
      {
        rv$chk <- reportilo::get_checklist(input$guideline)
      },
      ignoreInit = FALSE
    )

    output$badge <- renderUI({
      req(rv$chk)
      if (isTRUE(attr(rv$chk, "verified"))) {
        tags$span(class = "badge bg-success", "Hand-verified checklist")
      } else {
        tags$span(class = "badge bg-warning text-dark", "Auto-extracted (verify against source)")
      }
    })

    output$table <- DT::renderDT(
      {
        req(rv$chk)
        DT::datatable(
          as.data.frame(rv$chk),
          rownames = FALSE,
          editable = list(target = "cell", disable = list(columns = 0:2)),
          options = list(pageLength = 25, scrollX = TRUE)
        )
      },
      server = FALSE
    )

    observeEvent(input$table_cell_edit, {
      info <- input$table_cell_edit
      chk <- rv$chk
      chk[info$row, info$col + 1] <- info$value # col is 0-based, rownames off
      rv$chk <- chk
    })

    dl <- function(ext) {
      downloadHandler(
        filename = function() paste0(input$guideline, "_checklist.", ext),
        content = function(file) notify_export(reportilo::reportilo_export(rv$chk, file, format = ext), ext)
      )
    }
    output$dl_docx <- dl("docx")
    output$dl_xlsx <- dl("xlsx")
    output$dl_csv <- dl("csv")
  })
}

# =========================== Flow diagram module ===========================
flowchartUI <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      width = 360,
      selectInput(ns("template"), "Template", choices = template_choices),
      uiOutput(ns("fields")),
      downloadButton(ns("dl_png"), "PNG", class = "btn-primary btn-sm"),
      downloadButton(ns("dl_svg"), "SVG", class = "btn-secondary btn-sm"),
      downloadButton(ns("dl_pdf"), "PDF", class = "btn-outline-secondary btn-sm"),
      downloadButton(ns("dl_docx"), "Word", class = "btn-outline-secondary btn-sm")
    ),
    card(full_screen = TRUE, card_header("Preview"), DiagrammeR::grVizOutput(ns("preview"), height = "640px"))
  )
}

flowchartServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    fields <- reactive(reportilo::flowchart_fields(input$template))

    output$fields <- renderUI({
      ns <- session$ns
      f <- fields()
      lapply(seq_len(nrow(f)), function(i) {
        fid <- ns(paste0("fld_", f$count_field[i]))
        if (isTRUE(f$is_reasons[i])) {
          textInput(fid, f$label[i], value = f$value[i])
        } else {
          numericInput(fid, f$label[i], value = suppressWarnings(as.numeric(f$value[i])) %||% 0, min = 0)
        }
      })
    })

    fc <- reactive({
      f <- fields()
      obj <- reportilo::new_flowchart(input$template)
      vals <- list()
      for (i in seq_len(nrow(f))) {
        v <- input[[paste0("fld_", f$count_field[i])]]
        if (!is.null(v)) vals[[f$count_field[i]]] <- v
      }
      if (length(vals)) obj <- do.call(reportilo::set_counts, c(list(obj), vals))
      obj
    })

    output$preview <- DiagrammeR::renderGrViz({
      DiagrammeR::grViz(reportilo::flowchart_dot(fc()))
    })

    dl <- function(ext) {
      downloadHandler(
        filename = function() paste0(input$template, ".", ext),
        content = function(file) notify_export(reportilo::reportilo_export(fc(), file, format = ext), ext)
      )
    }
    output$dl_png <- dl("png")
    output$dl_svg <- dl("svg")
    output$dl_pdf <- dl("pdf")
    output$dl_docx <- dl("docx")
  })
}

# ================================== App ====================================
ui <- page_navbar(
  title = "reportilo",
  theme = theme,
  fillable = TRUE,
  nav_panel("Catalog", icon = icon("table-list"), catalogUI("catalog")),
  nav_panel("Checklists", icon = icon("list-check"), checklistUI("checklist")),
  nav_panel("Flow diagrams", icon = icon("diagram-project"), flowchartUI("flow")),
  nav_spacer(),
  nav_item(tags$a(href = "https://choxos.github.io/reportilo/", "Docs", target = "_blank")),
  nav_item(tags$a(href = "https://github.com/choxos/reportilo", "GitHub", target = "_blank"))
)

server <- function(input, output, session) {
  catalogServer("catalog")
  checklistServer("checklist")
  flowchartServer("flow")
}

shinyApp(ui, server)
