server <- function(input, output, session) {
        
        output$user_out <- renderPrint({
                session$userData$user()
        })
        
        observeEvent(input$sign_out, {
                sign_out_from_shiny()
                session$reload()
        })
        
        
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
        
        # Create the table for the studies and measures to show in
        output$table <- renderDT({
                # Get the column indices from their names
                # Subtract 1 to convert to 0-based indexing
                prefix_index <- which(names(data) == "Prefix") - 1
                urls_index <- which(names(data) == "URLs") - 1
                
                # Get the column indices of the unchecked studies
                # get the indices of the unchecked study columns
                unchecked_studies_indices <- which(!names(data) %in% c("Prefix", "URLs", "Number of Items", "Subscales", input$studies)) - 1
                
                ## debugging
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
                                          }"
                                         )
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
                              "
                          ),
                          rownames = FALSE
                )
        })
        
        observeEvent(input$measure_checkbox, {
                print("Checkbox value:")
                print(input$measure_checkbox)
                
                # Check if input$measure_checkbox is NULL or empty
                if (is.null(input$measure_checkbox) || length(input$measure_checkbox) == 0) {
                        print("No checkboxes checked")
                        selected_rows_temp <- data.frame(Cart = "Cart is empty")
                } else {
                        # Remove the c() function and quotes from the string
                        measure_checkbox_string <- gsub("c\\(|\\)|\"", "", input$measure_checkbox)
                        
                        # Split the string into a vector of strings
                        measure_checkbox_values <- unlist(strsplit(measure_checkbox_string, ","))
                        
                        # Remove leading and trailing white spaces from each value
                        measure_checkbox_values <- trimws(measure_checkbox_values)
                        
                        # Convert the tibble to a vector
                        prefix_vector <- unlist(filtered_by_study()[, "Prefix"])
                        
                        # Get the indices of the rows where the Prefix is in measure_checkbox_values
                        selected_rows_indices <- which(prefix_vector %in% measure_checkbox_values)
                        
                        print(selected_rows_indices)
                        
                        # If there are any selected rows, subset the rows using the indices
                        # Otherwise, create an empty data frame
                        if (length(selected_rows_indices) > 0) {
                                selected_rows_temp <- filtered_by_study()[selected_rows_indices, ]
                        } else {
                                selected_rows_temp <- data.frame(Cart = "Cart is empty")
                        }
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
                        
                        # Check if selected_rows() has any rows or if no studies are selected
                        if (is.null(input$studies) || nrow(selected_rows()) == 0) {
                                # Return a data frame with a single cell containing the message "Cart is empty"
                                data.frame(Cart = "Cart is empty")
                        } else {
                                # Subset to include only the "Prefix" column
                                selected_rows()[, "Prefix", drop = FALSE]
                        }
                },
                caption = htmltools::HTML("<i class='fa fa-shopping-cart'></i> Cart"),
                options = list(
                        # Set the initial number of rows to 10
                        pageLength = 10,
                        # Increase the height of the scrollable area
                        scrollY = "400px",
                        # Adjust the table height to fit the number of rows
                        scrollCollapse = TRUE,
                        paging = FALSE
                ),
                # Use client-side processing
                server = FALSE,
                rownames = FALSE
        )
        
        
        # Observe the checkout button , This will eventually be the function to send the data to the database
        observeEvent(input$checkout, {
                # Check if the cart is empty
                if (nrow(selected_rows()) == 0) {
                        # Show the modal dialog with the message "Cart is Empty"
                        showModal(modalDialog(
                                title = "Checkout",
                                "Cart is Empty",
                                easyClose = TRUE,
                                footer = NULL
                        ))
                } else {
                        # Show the modal dialog with the message "Your cart has been sent for approval."
                        showModal(modalDialog(
                                title = "Checkout",
                                "Your cart has been sent for approval.",
                                easyClose = TRUE,
                                footer = NULL
                        ))
                }
        })
        
}

secure_server(server)