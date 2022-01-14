shinyUI(
  tagList(
    navbarPage(
      
      # Theme options
      use_theme(
        create_theme(
          theme = "default",
          bs_vars_navbar(
            default_bg = ktcPalette["ktcMenuBlue"],
            default_link_color = ktcPalette["ktcBlue"],
            default_link_active_color = "#FFFFFF",
            default_link_hover_color = "#FFFFFF",
            height = "45px",
          ),
          bs_vars_font(
            family_sans_serif = "Lato",
            size_base = "14px",
          ),
          bs_vars_color(
            brand_primary = ktcPalette["ktcBlue"],
          )
        )
      ),
      
      # Window title
      windowTitle = "Dynasty Value Tool | KeepTradeCut",
      
      # Title image
      title = img(src = "ktc-gif.gif", 
                  style = 'margin-top: 0px', 
                  height = "40px"),
      
      # Attributes tab
      tabPanel(h4("Attributes"),
               sidebarLayout(
                 sidebarPanel(
                   shiny_data_filter_ui("export_filter"),
                   div(class = 'text-center', downloadButton('download', 'Download')),
                   width = 3
                 ),
                 mainPanel(
                   wellPanel(DTOutput('data_table')),
                   width = 9
                 )
               )  
      ),
      
      # Positions tab
      tabPanel(h4("Positions"),
               sidebarPanel(
                 p(strong("Group 1"), style = "text-align: center;"),
                 shiny_data_filter_ui("compare_filter_1"),
                 width = 3
               ),
               mainPanel(
                 fluidRow(
                   actionButton(
                     inputId = "go",
                     label = "Compare Groups",
                     style = "color: #FFFFFF; background-color: #0A3254; border-color: #FFFFFF;"
                   ),
                   align = "center",
                   style = 'padding:10px;'
                 ),
                 tabsetPanel(
                   tabPanel("Demographics",
                            fluidRow(plotlyOutput("plot_race", height = "200px"), 
                                     plotlyOutput("plot_ethnicity", height = "200px"),
                                     plotlyOutput("plot_sex", height = "200px"),
                                     plotlyOutput("plot_age", height = "200px")
                            )
                   ),
                   tabPanel("Action Taken", plotlyOutput("plot_action")),
                   tabPanel("Loan Amounts", plotlyOutput("plot_amounts")),
                   tabPanel("Denial Reasons", plotlyOutput("plot_denial")),
                 ),
                 width = 6
               ),
               sidebarPanel(
                 p(strong("Group 2"), style = "text-align: center;"),
                 shiny_data_filter_ui("compare_filter_2"),
                 width = 3
               )
      ),
      
      # Players tab
      tabPanel(h4("Players"),
               sidebarLayout(
                 sidebarPanel(
                   shiny_data_filter_ui("export_filter"),
                   selectInput("player1",
                               "Select Player 1",
                               dynasty$name,),
                   selectInput("player2",
                               "Select Player 2",
                               dynasty$name),
                   dateRangeInput("player_dates",
                                  "Date range:",
                                  start = min(dynasty$date),
                                  end = max(dynasty$date),
                                  min = min(dynasty$date),
                                  max = max(dynasty$date),
                                  startview = "month",
                                  weekstart = 2
                   ),
                   width = 3
                 ),
                 mainPanel(
                   fluidRow(
                     column(
                       #playerOneCard(),
                       width = 6
                     ),
                     column(
                       #playerTwoCard(),
                       width = 6
                     )
                   ),
                   fluidRow(
                     column(
                       plotlyOutput("dynasty_comparison"),
                       width = 6
                     ),
                     column(
                       #plotlyOutput("fantasy_history"),
                       width = 6
                     )
                   )
                 )
              )
            )
    )
  )
)