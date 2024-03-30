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
  skin = "blue",
  dashboardHeader(title = "Data Catalog"),
  dashboardSidebar(disable = TRUE), # Disable the sidebar
  dashboardBody(
    # Allows custom JavaScript code to be executed
    useShinyjs(),
    # Add custom CSS styles to the checkbox group and logo
    tags$head(tags$style(HTML("
      .shiny-input-checkbox-group .shiny-input-container {
        border-radius: 5px;  # Add rounded corners
      }
      caption {
        caption-side: top;
        font-size: 2em;  # Adjust the font size as needed
        font-weight: bold;  # Make the font bold
      }
    "))),
    # Add a logo
    # tags$img(inputId = "logo", src = "www/logo.png", height = 100, width = 200),
    # Add a custom div for the dropdown button for selecting studies
    div(
      dropdownButton(
        # Add the checkbox group for selecting studies
        shiny::checkboxGroupInput(inputId = "studies", label = NULL, choices = c("EEG", "Lyme", "ALZ", "MDD/AUD"), selected = c("EEG", "Lyme", "ALZ", "MDD/AUD")),
        label = "Select Studies",
        status = "primary",
        circle = "false"
      )
    ),
    # Add the DataTable for the selected data
    DT::dataTableOutput(outputId = "table"),
    # Add the DataTable for the cart
    fluidRow(
      column(6, DT::dataTableOutput(outputId = "selected_table"))
    ),
    # Add the checkout button to submit the selected data for processing
    actionButton(inputId = "checkout", label = "Checkout")
  )
)

# Define the server function
server <- function(input, output, session) {
  # Load the data, # this would ideally be the database connection/ call
  data <- read_excel("dataharmSAM.xlsx")

  # Create a reactive data frame that filters the data based on the selected studies
  filtered_by_study <- reactive({
    if (is.null(input$studies)) {
      return(data.frame())
    } else {
      # Filter the data based on the selected studies. If the study is selected, return the row where the study is "X"
      return(data[apply(data[input$studies], 1, function(x) any(x == "X")), ])
    }
  })

  # Create a reactive value to store the selected rows
  selected_rows <- reactiveVal(data.frame())

  output$table <- renderDT({
    # Get the column indices from their names
    # Subtract 1 to convert to 0-based indexing
    prefix_index <- which(names(data) == "Prefix") - 1
    urls_index <- which(names(data) == "URLs") - 1

    # Get the column indices of the unchecked studies
    # get the indices of the unchecked study columns
    unchecked_studies_indices <- which(!names(data) %in% c("Prefix", "URLs", "Number of Items", "Subscales", input$studies)) - 1

    # print(unchecked_studies_indices)
    # print(input$studies)
    # print(which(!names(data) %in% c("Prefix", "URLs", "Number of Items", "Subscales", input$studies)))

    # Render the filtered data
    datatable(filtered_by_study(),
      # Add the buttons extension which includes the column visibility button
      extensions = "Buttons",
      options = list(
        # Add the buttons to the top of the table, these buttons are: copy, csv, excel, pdf, print
        dom = "Bfrtip",
        # Add the column visibility button
        buttons = list("colvis"),
        columnDefs = list(
          # Hide the URLs column and the columns of the unchecked studies
          list(visible = FALSE, targets = c(urls_index, unchecked_studies_indices))
        ),
        # Add the checkboxes to the first column
        rowCallback = JS(
          paste0("function(row, data) {
            var $checkbox = $('<input type=\"checkbox\" class=\"measure-checkbox\" value=\"' + data[", prefix_index, "] + '\"> ' + data[", prefix_index, "] + '</a>');
            $('td:eq(", prefix_index, ")', row).html($checkbox);
          }")
        ),
        # Set the initial number of rows to 10
        pageLength = 10,
        # Increase the height of the scrollable area
        scrollY = "400px",
        # Adjust the table height to fit the number of rows
        scrollCollapse = TRUE,
        # Disable pagination
        paging = FALSE
      ),

      # Add the JavaScript callback to update shiny input when the checkbox is changed
      callback = JS("
        table.on('change', '.measure-checkbox', function() {
          console.log('Checkbox changed');
          Shiny.setInputValue('measure_checkbox', $('.measure-checkbox:checked').map(function() { return $(this).val(); }).get());
        });
      "),
      rownames = FALSE
    )
  })

  # Observe the changes in the measure_checkbox input (when the checkboxes are changed, selected = TRUE)
  observeEvent(input$measure_checkbox, {
    # Remove the c() function and quotes from the string
    measure_checkbox_string <- gsub("c\\(|\\)|\"", "", input$measure_checkbox)

    # Split the string into a vector of strings
    measure_checkbox_values <- unlist(strsplit(measure_checkbox_string, ","))

    # Remove leading and trailing white spaces from each value
    measure_checkbox_values <- trimws(measure_checkbox_values)

    # Convert the tibble to a vector
    prefix_vector <- unlist(filtered_by_study()[, "Prefix"])

    # print(measure_checkbox_values)
    # print(prefix_vector)
    # print(measure_checkbox_values %in% prefix_vector)

    # Get the indices of the rows where the Prefix is in measure_checkbox_values
    selected_rows_indices <- which(prefix_vector %in% measure_checkbox_values)

    # If there are any selected rows, subset the rows using the indices
    # Otherwise, create an empty data frame
    if (length(selected_rows_indices) > 0) {
      selected_rows_temp <- filtered_by_study()[selected_rows_indices, ]
    } else {
      selected_rows_temp <- data.frame()
    }

    # Update the reactive value
    selected_rows(selected_rows_temp)

    # print(selected_rows)
  })

  # Render the cart table
  output$selected_table <- DT::renderDataTable(
    {
      # Ensure that selected_rows() is available
      req(selected_rows())
      # Check if selected_rows() has any rows
      if (nrow(selected_rows()) > 0) {
        # Subset to include only the "Prefix" column
        selected_rows()[, "Prefix", drop = FALSE]
      } else {
        # Return a data frame with a single cell containing the message "Cart is empty"
        data.frame(Cart = "Cart is empty")
      }
    },
    caption = "Cart",
    options = list(
      paging = FALSE
    ),
    # Use client-side processing
    server = FALSE
  )
}

# Run the app
shinyApp(ui, server)
