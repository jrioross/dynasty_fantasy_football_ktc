shinyServer(function(input, output) {
  
  # ATTRIBUTES TAB
  
  ## Reactive Filters
  attrPlayer <- reactive({
    
    dynasty %>%
      filter(name == input$attrPlayerSelection,
             date == max(date))
    
  })
  
  attrPos <- reactive({
    
    dynasty %>%
      filter(Position %in% input$attrPosSelection,
             date == max(date))
      
  })
  
  ## Reactive Values
  v <- reactiveValues(xVar = "Age")
  
  observeEvent(input$xAge, {
    v$xVar <- "Age"
  })
  
  observeEvent(input$xExp, {
    v$xVar <- "Experience"
  })
  
  observeEvent(input$xHeight, {
    v$xVar <- "Height"
  })
  
  observeEvent(input$xWeight, {
    v$xVar <- "Weight"
  })
  
  observeEvent(input$xDraftRound, {
    v$xVar <- "`Draft Round`"
  })
  
  observeEvent(input$xDraftOverall, {
    v$xVar <- "`Draft Overall Pick`"
  })
  
  ## Plots
  
  ### attributes correlation matrix
  output$corrGraph <- renderPlotly({
    
    dyCorr <- attrPos() %>%
      select(-name, -Drafted, -College, -date, -Born, -Position) %>%
      cor(use = "pairwise.complete.obs")
    
    p.mat <- attrPos() %>%
      select(-name, -Drafted, -College, -date, -Born, -Position) %>%
      ggcorrplot::cor_pmat()
    
    heatmaply::heatmaply_cor(
      dyCorr,
      colors = c(ktcPalette['ktcDarkRed'], "white", ktcPalette['ktcMenuBlue']),
      label_names = c("x", "y", "Correlation"),
      Rowv = FALSE,
      Colv = FALSE,
      main = "Correlations of Attributes & Dynasty Value"
    )
    
  })
  

  ### attributes & dynasty value scatterplot
  output$attrScatter <- renderPlotly({
    
    val_draft <- dynasty %>% 
      filter(date == max(date)) %>%
      drop_na(Position) %>%
      ggplot(aes(x = eval(parse(text = v$xVar)), 
                 y = value), 
             ) +
      geom_point(color = ktcPalette['ktcDarkGrey'], 
                 alpha = 0.3,
                 aes(text = sprintf("Name: %s<br>%s: %s<br>Value: %s<br>Position: %s",
                                    name, v$xVar, eval(parse(text = v$xVar)), value, Position
                                    )
                     )
                 ) +
      geom_point(data = attrPlayer(),
                 aes(x = eval(parse(text = v$xVar)),
                     y = value,
                     text = sprintf("Name: %s<br>%s: %s<br>Value: %s<br>Position: %s",
                                    name, v$xVar, eval(parse(text = v$xVar)), value, Position
                                    )
                     ),
                 color = ktcPalette['ktcBlue'],
                 size = 2.5
                 )+
      geom_smooth(se = FALSE, 
                  color = ktcPalette['ktcLightRed'],
                  alpha = 0.4) +
      facet_wrap(~Position) +
      labs(x = v$xVar,
           y = "Dynasty Value")
    
    ggplotly(val_draft, 
             tooltip = 'text'
             ) %>%
      layout(title = list(text = sprintf("Dynasty Value v %s by Position", v$xVar), font = list(size = 20)))
    
  })
  
  ### college & dynasty value correlation matrix
  output$collegeCorr <- renderPlotly({
    
    dynasty_college <- attrPos() %>%
      select(value, College) %>%
      drop_na(College) %>%
      group_by(College) %>%
      mutate(n = n()) %>%
      filter(n >= 4) %>% 
      arrange(desc(n)) %>%
      select(-n)
    
    dummy <- model.matrix(~0+., data=dynasty_college) 
    colnames(dummy) <- sub("College", "", colnames(dummy))
    
    p.matTrimmed <- cor_pmat(dummy)[,1, drop = FALSE]
    
    corTrimmed <- cor(dummy, use="pairwise.complete.obs")[,1, drop = FALSE]
    
    heatmaply::heatmaply_cor(
      t(corTrimmed),
      label_names = c("x", "y", "Correlation"),
      colors = c(ktcPalette['ktcDarkRed'], "white", ktcPalette['ktcMenuBlue']),
      Rowv = FALSE,
      Colv = FALSE,
      main = "Correlations of College & Dynasty Value",
      xlab = "College"
    )
    
  })
  
  # POSITIONS TAB
  
  ## Reactive Filters
  posPlayer <- reactive({
    
    dynasty %>%
      filter(name == input$posPlayerSelection)
    
  })
  
  posPos <- reactive({
    
    dynasty %>%
      filter(Position %in% input$posPosSelection)
    
  })
  

  posDynasty <- reactive({
    
    posPos() %>%
      group_by(Position, date) %>%
      summarize(`Position Mean` = mean(value),
             `Position Max` = max(value),
             `Position Q3` = quantile(value, probs = 0.75),
             `Position Median` = median(value),
             `Position Q1` = quantile(value, probs = 0.25),
             `Position Min` = min(value))
    
  })
  
  ## Plots
  
  ### dynasty values by position boxplot
  output$posBox <- renderPlotly({
    
    d <- posPos() %>%
      filter(date == max(date)) %>% 
      mutate(Position = factor(Position, levels = c("QB", "RB", "WR", "TE")))
    
    vals_by_position <- ggplot() +
        geom_boxplot(data = d, aes(x = Position, y = value, fill = Position)) +
        geom_point(data = posPlayer()%>% filter(date == max(date)), aes(x = Position, y = value),
                   color = ktcPalette['ktcBlue'],
                   size = 2.5) +
        scale_fill_manual(values = c("QB" = '#0B5680',
                                     "RB" = '#136C9D',
                                     "WR" = '#EE8590',
                                     "TE" = '#E85262'
                          )) +
        labs(title = "Dynasty Values by Position",
             y = "Dynasty Value")

    
    ggplotly(vals_by_position)
    
  })
  
  ### dynasty value snapshot scatter
  output$posScatter <- renderPlotly({
    

    ggplot() +
      geom_point(data = posPlayer()%>% filter(date == max(date)), aes(x = date, y = value),
                 color = ktcPalette['ktcBlue'],
                 size = 2.5) +
      geom_jitter(data = posPos() %>% filter(date == max(date)), aes(x = date, y = value),
                  alpha = 0.3) +
      labs(title = "Player Value Compared to Selected Positions",
           x = "Date",
           y = "Dynasty Value")
    
  })

  ### dynasty value player vs position over time ("boxplot timeline")
  output$playerVposition <- renderPlotly({

    #transition_reveal(gameday)
    
    playerPos <- posPlayer() %>%
      filter(date == min(date)) %>%
      select(Position) %>%
      unique()
    
    posData <- posDynasty() %>%
      filter(Position %in% playerPos)
    
    pp <- ggplot() +
      geom_line(data = posPlayer(), aes(x = date, y = value), color = ktcPalette['ktcBlue'])+
      geom_line(data = posData, aes(x = date, y = `Position Median`)) +
      geom_line(data = posData, aes(x = date, y = `Position Max`)) +
      geom_line(data = posData, aes(x = date, y = `Position Q3`)) +
      geom_line(data = posData, aes(x = date, y = `Position Q1`)) +
      geom_line(data = posData, aes(x = date, y = `Position Min`)) +
      geom_ribbon(data=posData, 
                  aes(x = date, ymin=`Position Q1`,ymax=`Position Q3`), fill=ktcPalette['ktcLightGrey'], alpha=0.2) +
      labs(title = "Player Value Compared to Position Boxplot over Time",
           x = "Date",
           y = "Dynasty Value") +
      scale_y_continuous(limits = c(0, 10000))
    
    ggplotly(pp)

  })
  
  # PLAYERS TAB
  
  ## Reactive Filters
  
  ### player1 and player2 dynasty
  player1_dynasty <- reactive({
    dynasty %>%
      filter(name == input$player1,
             between(date, input$playerDates[1], input$playerDates[2])
            )
  })
  
  player2_dynasty <- reactive({
    dynasty %>%
      filter(name == input$player2,
             between(date, input$playerDates[1], input$playerDates[2])
             )
  })
  
  ### player1 and player2 fantasy
  player1_fantasy <- reactive({
    fantasy %>%
      filter(full_name == input$player1,
             between(gameday, input$playerDates[1], input$playerDates[2])
             )
  })
  
  player2_fantasy <- reactive({
    fantasy %>%
      filter(full_name == input$player2,
             between(gameday, input$playerDates[1], input$playerDates[2])
             )
  })
  
  date1 <- reactive({
    input$playerDates[1]
  })
  
  date2 <- reactive({
    input$playerDates[2]
  })
  
  ## Plots
  
  ### player1 and player2 dynasty comparison
  output$dynasty_comparison <- renderPlotly({
    
    dc <- player1_dynasty() %>% 
      rbind(player2_dynasty()) %>%
      ggplot(aes(x = date, 
                 y = value, 
                 color = name,
                 group = 1,   # for some reason this keeps the lines from disappearing when I use the text aesthetic
                 text = sprintf("Player Name: %s<br>Date: %s<br>Dynasty Value: %s",
                                name, date, value)
                 )) +
      geom_line() +
      scale_color_manual(values = c("#EE8590", "#4DB3E9")) +
      labs(title = "Comparison of Dynasty Values over Time",
           x = "Date",
           y = "Dynasty Value",
           color = "Player Name") +
      xlim(date1(), date2()) +
      ylim(0, 10000)

    ggplotly(dc, tooltip = "text")
    
    })
  
  ### player1 and player2 fantasy comparison
  output$fantasy_comparison <- renderPlotly({
    
    comp_2020 <- player1_fantasy() %>%
      rbind(player2_fantasy()) %>%
      filter(season == 2020)

    comp_2021 <- player1_fantasy() %>%
      rbind(player2_fantasy()) %>%
      filter(season == 2021)
    
    p <- player1_fantasy() %>%
      rbind(player2_fantasy()) %>%
      ggplot(aes(x = gameday, y = fantasy_points_halfppr, 
                 color = full_name, 
                 label = paste0(round(fantasy_points_halfppr, 0)),
                 text = sprintf("Player Name: %s<br>Game Date: %s<br>Fantasy Points Half PPR: %s",
                                full_name, gameday, paste0(round(fantasy_points_halfppr, 0))))) +
        geom_segment(aes(x = gameday, y = 0, yend = fantasy_points_halfppr, xend = gameday), color = "grey50") +
        geom_point(size = 7) +
        geom_text(color = "white", size = 2) +
        scale_color_manual(values = c("#EE8590", "#4DB3E9")) +
        labs(title = "Comparison of Fantasy Performance over Time",
             x = "Game Date",
             y = "Fantasy Points Scored (Half PPR)",
             color = "Player Name") +
        xlim(date1(), date2())

    
    ggplotly(p, tooltip = 'text')
    
  })
  
  ## Player Cards
  
  ### player1 card image
  output$card1_img <- renderUI({
    
    src <- player1_fantasy() %>%
      filter(season == 2021) %>% 
      select(headshot_url) %>%
      unique()
    
    tags$img(src = src, width = 200, height = 150)
    
  })
  
  ### player1 card text
  output$card1_text <- renderText({
    
    fcontent <- player1_fantasy() %>% 
      filter(gameday == max(gameday))
    
    dcontent <- player1_dynasty() %>%
      filter(date == max(date))
    
    paste0("<b>Name: ", input$player1, "</b>",
           "<br>Position: ", dcontent %>% select(Position) %>% unique(),
           "<br>Team: ", fcontent %>% select(recent_team),
           "<br>Age: ", dcontent %>% select(Age) %>% unique(),
           "<br>Experience: ", dcontent %>% select(Experience) %>% unique(),
           "<br>Height: ", dcontent %>% select(Height) %>% unique(),
           "<br>Weight: ", dcontent %>% select(Weight) %>% unique(),
           "<br><br><br><br><br><br>")
    
  })
  
  ### player2 card image
  output$card2_img <- renderUI({
    
    src <- player2_fantasy() %>%
      filter(season == 2021) %>% 
      select(headshot_url) %>%
      unique()
    
    tags$img(src = src, width = 200, height = 150)
    
  })
  
  ### player2 card text
  output$card2_text <- renderText({
    
    fcontent <- player2_fantasy() %>% 
      filter(gameday == max(gameday))
    
    dcontent <- player2_dynasty() %>%
      filter(date == max(date))
    
    paste0("<b>Name: ", input$player2, "</b>",
           "<br>Position: ", dcontent %>% select(Position) %>% unique(),
           "<br>Team: ", fcontent %>% select(recent_team),
           "<br>Age: ", dcontent %>% select(Age) %>% unique(),
           "<br>Experience: ", dcontent %>% select(Experience) %>% unique(),
           "<br>Height: ", dcontent %>% select(Height) %>% unique(),
           "<br>Weight: ", dcontent %>% select(Weight) %>% unique(),
           "<br><br><br><br><br><br>")
    
  })
  
})

