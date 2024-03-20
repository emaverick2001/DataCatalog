# Load the shiny and readxl packages
library(shiny)
library(DT)
library(readxl)

ui <- fluidPage( # fluidPage is a layout for creating a Shiny app that uses the full width of the browser
  selectInput("dataset", label = "Dataset", choices = ls("package:datasets")), 
  verbatimTextOutput("summary"),
  tableOutput("table"),
)

server <- function(input, output, session) {
  # Create a reactive expression
  dataset <- reactive({
    get(input$dataset, "package:datasets")
  })

  output$summary <- renderPrint({
    # Use a reactive expression by calling it like a function
    summary(dataset())
  })
  
  output$table <- renderTable({
    dataset()
  })

}
shinyApp(ui, server)
 