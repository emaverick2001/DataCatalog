# Load the necessary packages
library(shiny)
library(shinythemes)
library(readxl)
library(DT)
library(shinyWidgets)
library(shinyjs)
library(shinydashboard)

# Define the UI
ui <- dashboardPage(
  dashboardHeader(title = "Data Catalog"),
  dashboardBody(
    useShinyjs(), # Enable shinyjs
    tags$head(tags$style(HTML("
      .custom-header {
        background-color: #007BA7;
        color: #ffffff;
        padding: 20px;
        font-size: 24px;
        font-weight: bold;
      }
      .shiny-input-checkbox-group .shiny-input-container {
        border-radius: 5px;  # Add rounded corners
      }
      #logo {
        display: block;
        margin: auto;
      }
    "))),
    wellPanel(
      class = "custom-header",
      "Data Catalog"
    ), # Add a custom header
    tags$img(id = "logo", src = "www/logo.png", height = 100, width = 200), # Add a logo
    div(
      id = "studies-dropdown",
      dropdownButton(
        checkboxGroupInput("studies", NULL, choices = c("EEG", "Lyme", "ALZ", "MDD/AUD"), selected = c("EEG", "Lyme", "ALZ", "MDD/AUD")),
        label = "Select Studies", status = "primary", circle = "false"
      )
    ),
    DT::dataTableOutput("table"),
  )
)

# Define the server function
server <- function(input, output, session) {
  # Load the data
  data <- read_excel("dataharmSAM.xlsx") # this would ideally be the database connection/ call

  # Create a reactive data frame that filters the data based on the selected studies
  filtered_data <- reactive({
    if (is.null(input$studies)) {
      return(data.frame())
    } else {
      return(data[apply(data[input$studies], 1, function(x) any(x == "X")), ])
    }
  })

  output$table <- renderDT({
    # Get the column indices from their names
    prefix_index <- which(names(data) == "Prefix") - 1
    urls_index <- which(names(data) == "URLs") - 1

    # Get the column indices of the unchecked studies
    unchecked_studies_indices <- which(!names(data) %in% c("Prefix", "URLs", "Number of Items", "Subscales", input$studies)) - 1

    datatable(filtered_data(),
      extensions = "Buttons",
      options = list(
        dom = "Bfrtip",
        buttons = list("colvis"),
        columnDefs = list(
          list(visible = FALSE, targets = c(urls_index, unchecked_studies_indices)) # Hide the URLs column and the columns of the unchecked studies
        ),
        rowCallback = JS(
          paste0("function(row, data) {
                    $('td:eq(", prefix_index, ")', row).html('<input type=\"checkbox\" class=\"measure-checkbox\" value=\"' + data[", prefix_index, "] + '\">' + data[", prefix_index, "] + '</a>');
                  }")
        ),
        pageLength = 10, # Set the initial number of rows to 10
        scrollY = "400px", # Increase the height of the scrollable area
        scrollCollapse = TRUE, # Adjust the table height to fit the number of rows
        paging = FALSE # Disable pagination
      ), rownames = FALSE
    )
  })
}

# Run the app
shinyApp(ui, server)
