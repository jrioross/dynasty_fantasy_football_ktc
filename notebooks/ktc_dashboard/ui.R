shinyUI(
  tagList(
    navbarPage(
      
      # Theme options
      use_theme(
        create_theme(
          theme = "default",
          bs_vars_navbar(
            default_bg = ktcPalette["ktcLightGrey"],
            default_link_color = ktcPalette["ktcBlue"],
            default_link_active_color = ktcPalette["ktcLightRed"],
            default_link_hover_color = "#FFFFFF",
            height = "45px",
          ),
          bs_vars_font(
            family_sans_serif = "Helvetica",
            size_base = "14px",
          ),
          bs_vars_color(
            brand_primary = ktcPalette["ktcBlue"],
          ),
          bs_vars_wells(
            #bg = ktcPalette["ktcLightGrey"]
          )
        )
      ),
      
      # Window title
      windowTitle = "Dynasty Value Tool | KeepTradeCut",
      
      # Title image
      title = tags$a(img(src = "ktc-gif.gif", 
                  style = 'margin-top: 0px', 
                  height = "40px"),
                  href = "https://keeptradecut.com/"),
      
      # Attributes tab
      tabPanel(h4("Research Player Attributes"),
               sidebarLayout(
                 sidebarPanel(
                   #shiny_data_filter_ui("export_filter"),
                   checkboxGroupInput("attrPosSelection",
                               "Select Position(s)",
                               positionsList,
                               selected = positionsList),
                   #actionButton('debug', "Debug"),
                   width = 2
                 ),
                 mainPanel(
                   fluidRow(
                     column(
                       width = 6,
                       div(style = "text-align:center; font-size:18px;",
                           HTML('<b>Correlations of Attributes & Dynasty Value</b>')),
                       plotOutput("corrGraph")
                     ),
                     column(
                       width = 6,
                       div(style = "text-align:center; font-size:18px; font-weight:bold;",
                           htmlOutput("attrScatterTitle")),
                       plotlyOutput("attrScatter"),
                       actionButton("xAge", "Age"),
                       actionButton("xExp", "Experience"),
                       actionButton("xHeight", "Height"),
                       actionButton("xWeight", "Weight"),
                       actionButton("xDraftRound", "Draft Round"),
                       actionButton("xDraftOverall", "Draft Overall Pick")
                     )
                   ),
                   tags$style(type='text/css', "#attrScatter {margin-bottom: 15px;}"),
                   fluidRow(
                     column(
                       width = 12,
                       # div(style = "vertical-align:bottom; text-align:center; font-size:18px; font-weight:bold;",
                       #     "Correlations between College and Dynasty Value"),
                       plotOutput("collegeCorr")
                     )
                   )
                 )
               )
      ),
      
      # Positions tab
      tabPanel(h4("Research Player v Positions"),
               sidebarLayout(
                 sidebarPanel(
                   selectInput("posPlayerSelection",
                               "Select Player 1",
                               playerList,
                               selected = "Jonathan Taylor"),
                   checkboxGroupInput("posPosSelection",
                                      "Select Position(s)",
                                      positionsList,
                                      selected = positionsList),
                   #actionButton('debug', "Debug"),
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
                   ),
                   fluidRow(
                     column(
                       width = 12,
                       plotlyOutput("playerVposition")
                  )
               )
            )
          )
        )
      ),

      
      # Players tab
      tabPanel(h4("Research Player v Player"),
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
                   dateRangeInput("playerDates",
                                  "Date range:",
                                  start = min(dynasty$date),
                                  end = max(dynasty$date),
                                  min = min(dynasty$date),
                                  max = max(dynasty$date),
                                  startview = "month",
                                  weekstart = 2),
                   #actionButton('debug', "Debug"),
                   width = 2
                 ),
                 mainPanel(
                   fluidRow(
                     column(
                       style = paste0("border: 2px solid", ktcPalette['ktcBlue']),
                       htmlOutput("card1_img"),
                       htmlOutput("card1_text"),
                       width = 3
                     ),
                     column(
                       width = 9,
                       plotlyOutput("dynasty_comparison")
                     )
                   ),
                   fluidRow(
                     column(
                       style = paste0("border: 2px solid", ktcPalette['ktcLightRed']),
                       htmlOutput("card2_img"),
                       htmlOutput("card2_text"),
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