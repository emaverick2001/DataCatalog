# # Load the shiny and readxl packages
# library(shiny)
# library(DT)
# library(readxl)

# ui <- fluidPage( # fluidPage is a layout for creating a Shiny app that uses the full width of the browser
#   selectInput("dataset", label = "Dataset", choices = ls("package:datasets")), 
#   verbatimTextOutput("summary"),
#   tableOutput("table"),
# )

# server <- function(input, output, session) {
#   # Create a reactive expression
#   dataset <- reactive({
#     get(input$dataset, "package:datasets")
#   })

#   output$summary <- renderPrint({
#     # Use a reactive expression by calling it like a function
#     summary(dataset())
#   })
  
#   output$table <- renderTable({
#     dataset()
#   })

# }
# shinyApp(ui, server)
 

### ** Examples
## Only run examples in interactive R sessions
if (interactive()) {
ui <- fluidPage(
  checkboxGroupInput("variable", "Variables to show:",
                     c("Cylinders" = "cyl",
                       "Transmission" = "am",
                       "Gears" = "gear")),
  tableOutput("data")
)
server <- function(input, output, session) {
  output$data <- renderTable({
    mtcars[, c("mpg", input$variable), drop = FALSE]
  }, rownames = TRUE)
}
shinyApp(ui, server)
ui <- fluidPage(
  checkboxGroupInput("icons", "Choose icons:",
    choiceNames =
      list(icon("calendar"), icon("bed"),
           icon("cog"), icon("bug")),
    choiceValues =
      list("calendar", "bed", "cog", "bug")
  ),
  textOutput("txt")
)
server <- function(input, output, session) {
  output$txt <- renderText({
    icons <- paste(input$icons, collapse = ", ")
    paste("You chose", icons)
  })
}
shinyApp(ui, server)
}