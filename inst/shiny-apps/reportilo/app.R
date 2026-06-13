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
  secondary = "#1FA37A"
  # fonts: use the Bootstrap system-ui stack (no runtime Google font fetch)
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
category_tabs <- c("All", levels(guidelines$category))
templates <- reportilo::flowchart_templates
template_choices <- stats::setNames(templates$template_id, templates$name)
rob_tools_df <- reportilo::rob_tools_available()
rob_tool_choices <- stats::setNames(rob_tools_df$tool_id, rob_tools_df$name)

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
      checkboxInput(ns("checklist_only"), "Only guidelines with a checklist", FALSE),
      helpText("Pick a study type, then click a row for details. The main guideline of each family is listed first.")
    ),
    do.call(
      tabsetPanel,
      c(list(id = ns("cat"), type = "pills"), lapply(category_tabs, tabPanel))
    ),
    div(class = "pt-3", DT::DTOutput(ns("table"))),
    uiOutput(ns("detail"))
  )
}

catalogServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive({
      g <- guidelines
      if (isTRUE(input$checklist_only)) g <- g[g$has_checklist, ]
      cat <- input$cat %||% "All"
      if (!is.null(cat) && cat != "All") {
        g <- g[!is.na(g$category) & as.character(g$category) == cat, ]
      }
      if (nzchar(input$search %||% "")) {
        hay <- tolower(paste(g$acronym, g$title, g$study_design, g$clinical_area))
        g <- g[grepl(tolower(input$search), hay, fixed = TRUE), ]
      }
      # alphabetical by acronym; guidelines without an acronym go last
      no_acronym <- is.na(g$acronym) | !nzchar(g$acronym)
      g[order(no_acronym, tolower(ifelse(no_acronym, g$title, g$acronym))), ]
    })

    output$table <- DT::renderDT({
      g <- filtered()
      DT::datatable(
        data.frame(
          Acronym = g$acronym, Title = g$title, Category = as.character(g$category),
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
          if (!is.na(info$equator_url %||% NA)) tags$p(tags$a(href = info$equator_url, "EQUATOR page", target = "_blank", rel = "noopener noreferrer")),
          if (length(files)) {
            tags$ul(lapply(files, function(f) tags$li(tags$a(href = f$url, f$label %||% f$url, target = "_blank", rel = "noopener noreferrer"))))
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
      verified <- isTRUE(attr(rv$chk, "verified"))
      status <- attr(rv$chk, "status") %||% "parsed_ok"
      conf <- attr(rv$chk, "parse_confidence")
      method <- attr(rv$chk, "parse_method") %||% "unknown"
      needs_review <- isTRUE(attr(rv$chk, "needs_review"))

      badge <- if (verified) {
        tags$span(class = "badge bg-success", "Hand-verified")
      } else if (status == "parsed_ok") {
        tags$span(class = "badge bg-info text-dark", "Auto-extracted")
      } else {
        tags$span(class = "badge bg-warning text-dark", paste0("Auto-extracted (", status, ")"))
      }
      meta <- tags$span(
        class = "text-muted", style = "font-size:0.8em; margin-left:0.4rem;",
        sprintf(
          "method: %s%s", method,
          if (!is.na(conf)) sprintf(" | confidence: %.2f", conf) else ""
        )
      )
      warn <- if (!verified && (needs_review || status %in% c("partial", "failed"))) {
        div(
          class = "alert alert-warning p-2 mt-2", style = "font-size:0.85em;",
          tags$strong("Verify against the source. "),
          "This checklist was extracted automatically and may be incomplete or ",
          "mislabeled. Use guideline_info() / the source link, and check each item."
        )
      }
      tagList(div(badge, meta), warn)
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
      checkboxInput(ns("transparent"), "Transparent background", FALSE),
      checkboxInput(ns("complete"), "Final diagram (require exact accounting)", FALSE),
      checkboxInput(ns("allow_warn"), "Export despite consistency warnings", FALSE),
      downloadButton(ns("dl_png"), "PNG", class = "btn-primary btn-sm"),
      downloadButton(ns("dl_svg"), "SVG", class = "btn-secondary btn-sm"),
      downloadButton(ns("dl_pdf"), "PDF", class = "btn-outline-secondary btn-sm"),
      downloadButton(ns("dl_docx"), "Word", class = "btn-outline-secondary btn-sm"),
      downloadButton(ns("dl_xlsx"), "Excel", class = "btn-outline-secondary btn-sm"),
      downloadButton(ns("dl_csv"), "CSV (counts)", class = "btn-outline-secondary btn-sm")
    ),
    card(
      full_screen = TRUE, card_header("Preview"),
      uiOutput(ns("consistency")),
      DiagrammeR::grVizOutput(ns("preview"), height = "640px")
    )
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
        if (is.null(v)) next
        if (isTRUE(f$is_reasons[i])) {
          vals[[f$count_field[i]]] <- v
        } else {
          # ignore blank/invalid numeric inputs (keep the field default)
          num <- suppressWarnings(as.numeric(v))
          if (length(num) == 1 && is.finite(num) && num >= 0 && num == round(num)) {
            vals[[f$count_field[i]]] <- num
          }
        }
      }
      if (length(vals)) obj <- do.call(reportilo::set_counts, c(list(obj), vals))
      obj
    })

    bg <- reactive(if (isTRUE(input$transparent)) "transparent" else "white")

    output$consistency <- renderUI({
      issues <- reportilo::flowchart_consistency(fc(), complete = isTRUE(input$complete))
      if (!length(issues)) {
        return(NULL)
      }
      div(
        class = "alert alert-warning p-2", style = "font-size:0.85em;",
        tags$strong("Check these counts: "),
        tags$ul(lapply(issues, tags$li)),
        tags$div(
          class = "mt-1",
          "Exports are blocked until these are resolved. ",
          "Tick 'Export despite consistency warnings' to download a draft anyway."
        )
      )
    })

    output$preview <- DiagrammeR::renderGrViz({
      DiagrammeR::grViz(reportilo::flowchart_dot(fc(), background = bg()))
    })

    # strict export blocks inconsistent diagrams unless the user opts into a
    # draft; "Final diagram" widens the check to exact (complete) accounting
    dl <- function(ext) {
      downloadHandler(
        filename = function() paste0(input$template, ".", ext),
        content = function(file) {
          notify_export(
            reportilo::reportilo_export(fc(), file,
              format = ext, background = bg(),
              strict = !isTRUE(input$allow_warn), complete = isTRUE(input$complete)
            ),
            ext
          )
        }
      )
    }
    output$dl_png <- dl("png")
    output$dl_svg <- dl("svg")
    output$dl_pdf <- dl("pdf")
    output$dl_docx <- dl("docx")
    output$dl_xlsx <- dl("xlsx")
    output$dl_csv <- dl("csv")
  })
}

# =========================== Risk-of-bias module ===========================
robUI <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      width = 340,
      selectInput(ns("tool"), "Tool", choices = rob_tool_choices),
      radioButtons(ns("ptype"), "Plot",
        c("Traffic light" = "traffic_light", "Summary" = "summary")),
      checkboxInput(ns("transparent"), "Transparent background", FALSE),
      helpText("Edit each cell with a judgment (e.g. Low, High). Allowed values depend on the tool."),
      downloadButton(ns("dl_png"), "PNG", class = "btn-primary btn-sm"),
      downloadButton(ns("dl_svg"), "SVG", class = "btn-secondary btn-sm"),
      downloadButton(ns("dl_docx"), "Word", class = "btn-outline-secondary btn-sm"),
      downloadButton(ns("dl_xlsx"), "Excel", class = "btn-outline-secondary btn-sm"),
      downloadButton(ns("dl_csv"), "CSV", class = "btn-outline-secondary btn-sm")
    ),
    card(card_header("Assessment"), DT::DTOutput(ns("table"))),
    card(full_screen = TRUE, card_header("Preview"), plotOutput(ns("plot"), height = "520px"))
  )
}

robServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    rv <- reactiveValues(data = NULL)

    observeEvent(input$tool,
      {
        rv$data <- as.data.frame(reportilo::reportilo_rob(input$tool))
      },
      ignoreInit = FALSE
    )

    rob_obj <- reactive({
      req(rv$data)
      reportilo::reportilo_rob(input$tool, rv$data)
    })

    output$table <- DT::renderDT(
      {
        req(rv$data)
        DT::datatable(rv$data,
          rownames = FALSE, editable = list(target = "cell", disable = list(columns = 0)),
          options = list(dom = "t", pageLength = 50, scrollX = TRUE)
        )
      },
      server = FALSE
    )

    observeEvent(input$table_cell_edit, {
      info <- input$table_cell_edit
      d <- rv$data
      d[info$row, info$col + 1] <- info$value
      rv$data <- d
    })

    output$plot <- renderPlot({
      obj <- rob_obj()
      if (input$ptype == "summary") reportilo::rob_summary(obj) else reportilo::rob_traffic_light(obj)
    })

    rob_bg <- reactive(if (isTRUE(input$transparent)) "transparent" else "white")

    dl <- function(ext) {
      downloadHandler(
        filename = function() paste0(input$tool, "_rob.", ext),
        content = function(file) {
          notify_export(
            reportilo::reportilo_export(rob_obj(), file,
              format = ext, type = input$ptype, background = rob_bg()
            ),
            ext
          )
        }
      )
    }
    output$dl_png <- dl("png")
    output$dl_svg <- dl("svg")
    output$dl_docx <- dl("docx")
    output$dl_xlsx <- dl("xlsx")
    output$dl_csv <- dl("csv")
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
  nav_panel("Risk of bias", icon = icon("traffic-light"), robUI("rob")),
  nav_spacer(),
  nav_item(tags$a(href = "https://choxos.github.io/reportilo/", "Docs", target = "_blank", rel = "noopener noreferrer")),
  nav_item(tags$a(href = "https://github.com/choxos/reportilo", "GitHub", target = "_blank", rel = "noopener noreferrer"))
)

server <- function(input, output, session) {
  catalogServer("catalog")
  checklistServer("checklist")
  flowchartServer("flow")
  robServer("rob")
}

shinyApp(ui, server)
