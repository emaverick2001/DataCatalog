ui <- dashboardPage(
        skin = "blue",
        dashboardHeader(
                title = "Data Catalog",
                titleWidth = 300,  # Adjust the width of the title to create space for the sign-out button
                tags$li(
                        class = "dropdown",
                        actionButton("sign_out", "Sign Out", icon = icon("sign-out-alt")),
                        style = "margin-top: 15px; margin-left: auto;"
                )
        ),
        dashboardSidebar(disable = TRUE), # Disable the sidebar
        dashboardBody(
                
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
                      #logo-container {
                        text-align: center;  # Center the contents horizontally
                      }
                    "))),
                
                # Add a logo
                # Add an id to the container div
                div(id = "logo-container",
                    tags$img(inputId = "logo", src = "images/logo.png", alt = "CPCR logo", style = "width: 125px; margin-top: 30px; margin-bottom: 30px;")
                ),
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
                # add empty space between the table and the cart
                tags$br(),
                tags$br(),
                tags$br(),
                # Add the DataTable for the cart
                fluidRow(
                        column(3, DT::dataTableOutput(outputId = "selected_table"))
                ),
                # Add the checkout button to submit the selected data for processing
                actionButton(inputId = "checkout", label = "Checkout")
        )
)

# Customize your sign-in page UI with logos, text, and colors.
my_custom_sign_in_page <- sign_in_ui_default(
        color = "#006CB5",
        company_name = "CPCR",
        logo_top = tags$div(
                style = "display: flex; justify-content: center; align-items: center; height: 100%; margin-top: 100px;",
                tags$img(
                        src = "images/logo.png",
                        alt = "CPCR logo",
                        style = "width: 300px; border-radius: 4px;"
                )
        ),
        icon_href = "images/folder.png",
        background_image = "images/bayview.png"
)

secure_ui(ui,sign_in_page_ui = my_custom_sign_in_page)