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
                   #shiny_data_filter_ui("export_filter"),
                   checkboxGroupInput("attrPosSelection",
                               "Select Position(s)",
                               positionsList),
                   actionButton('debug', "Debug"),
                   width = 2
                 ),
                 mainPanel(
                   fluidRow(
                     column(
                       width = 4,
                       plotOutput("corrGraph")
                     ),
                     column(
                       width = 8,
                       plotlyOutput("attrScatter")
                     )
                   ),
                   fluidRow(
                     column(
                       width = 12,
                       plotlyOutput("fantasy_comparison")
                     )
                   )
                 )
               )
      ),
      
      # Positions tab
      tabPanel(h4("Positions"),
               sidebarLayout(
                 sidebarPanel(
                   selectInput("posPlayerSelection",
                               "Select Player 1",
                               playerList),
                   checkboxGroupInput("posPosSelection",
                                      "Select Position(s)",
                                      positionsList),
                   actionButton('debug', "Debug"),
                   width = 2
                 ),
                 mainPanel(
                   fluidRow(
                     column(
                       width = 6,
                       plotlyOutput("posBox")
                     ),
                     column(
                       width = 6,
                       plotlyOutput("posScatter")
                     )
                   ),
                   fluidRow(
                     column(
                       width = 6,
                       plotlyOutput("playerVposition")
                     )
                   )
                 )
               )
      ),
      
      # Players tab
      tabPanel(h4("Players"),
               sidebarLayout(
                 sidebarPanel(
                   #shiny_data_filter_ui("export_filter"),
                   selectInput("player1",
                               "Select Player 1",
                               playerList),
                   selectInput("player2",
                               "Select Player 2",
                               playerList,
                               selected = playerList[2]),
                   dateRangeInput("player_dates",
                                  "Date range:",
                                  start = min(dynasty$date),
                                  end = max(dynasty$date),
                                  min = min(dynasty$date),
                                  max = max(dynasty$date),
                                  startview = "month",
                                  weekstart = 2),
                   actionButton('debug', "Debug"),
                   width = 2
                 ),
                 mainPanel(
                   fluidRow(
                     column(
                       material_card(
                         title = "Player 1",
                         img("card1_img"),
                         htmlOutput("card1_text")
                       ),
                       width = 3
                     ),
                     column(
                       width = 9,
                       plotlyOutput("dynasty_comparison")
                     )
                   ),
                   fluidRow(
                     column(
                       material_card(
                         title = "Player 2",
                         img("card2_img"),
                         htmlOutput("card2_text")
                       ),
                       width = 3
                     ),
                     column(
                       width = 9,
                       plotlyOutput("fantasy_comparison")
                     )
                   )
                 )
              )
            )
    )
  )
)