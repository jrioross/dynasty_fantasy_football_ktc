shinyServer(function(input, output) {
  
  ### ATTRIBUTES TAB ###
  
  attrPos <- reactive({
    
    dynasty %>%
      filter(Position %in% input$attrPosSelection,
             date == max(date))
      
  })
  
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
  
  output$corrGraph <- renderPlot({
    
    dyCorr <- attrPos() %>%
      select(-name, -Drafted, -College, -date, -Born, -Position) %>%
      cor(use = "pairwise.complete.obs")
    
    p.mat <- attrPos() %>%
      select(-name, -Drafted, -College, -date, -Born, -Position) %>%
      ggcorrplot::cor_pmat()
    
    ggcorrplot(dyCorr,
               #title = "Correlations of Attributes & Dynasty Values",
               hc.order = TRUE,
               type = "upper",
               p.mat = p.mat,
               colors = c("#E85262", "white", "#136C9D"),
               ggtheme = theme_minimal,
               legend.title = "Correlation")
    
    #ggplotly(p)
    
  })
  
  output$attrScatterTitle <- renderText({
    
    sprintf("Dynasty Value vs. %s by Position", v$xVar)
    
  })
  
  output$attrScatter <- renderPlotly({
    
    val_draft <- dynasty %>% 
      filter(date == max(date)) %>%
      drop_na(Position) %>%
      ggplot(aes(x = eval(parse(text = v$xVar)), 
                 y = value, 
                 color = Position
      )) +
      geom_point(aes(text = sprintf("Name: %s<br>%s: %s<br>Value: %s<br>Position: %s",
                                    name, v$xVar, eval(parse(text = v$xVar)), value, Position
                                    
      ))) +
      geom_smooth(se = FALSE) +
      facet_wrap(~Position) +
      labs(x = v$xVar)
    
    ggplotly(val_draft, 
             tooltip = 'text'
             )
    
  })
  
  output$collegeCorr <- renderPlot({
    
    dynasty_college <- dynasty %>%
      filter(date == max(date)) %>%
      select(value, College) %>%
      drop_na(College) %>%
      group_by(College) %>%
      mutate(n = n()) %>%
      filter(n >= 10) %>% 
      arrange(desc(n)) %>%
      select(-n)
    
    dummy <- model.matrix(~0+., data=dynasty_college)
    colnames(dummy) <- sub("College", "", colnames(dummy))
    
    p.matTrimmed <- cor_pmat(dummy)[,1, drop = FALSE]
    
    corTrimmed <- cor(dummy, use="pairwise.complete.obs")[,1, drop = FALSE]
    
    ggcorrplot(corTrimmed,
               #
               title = "Correlations between College and Dynasty Value",
               colors = c("#E85262", "white", "#136C9D"),
               show.diag = F,
               type="lower",
               p.mat = p.matTrimmed,
               insig = "blank",
               ggtheme = theme_minimal,
               legend.title = "Correlation"
    ) +
      theme(axis.title = element_text(face = "bold", size = 14))
    
    #ggplotly(cp)
    
  })
  
  ### POSITIONS TAB ###
  
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
      summarize(pos_mean = mean(value),
             pos_max = max(value))
    
  })
  
  output$posBox <- renderPlotly({
    
    vals_by_position <- posPos() %>%
      filter(date == max(date)) %>% 
      ggplot(aes(x = Position, y = value, fill = Position)) +
        geom_boxplot() +
        labs(title = "Dynasty Values by Position")
    
    ggplotly(vals_by_position)
    
  })
  
  output$posScatter <- renderPlotly({
    

    ggplot() +
      geom_point(data = posPlayer()%>% filter(date == max(date)), aes(x = date, y = value),
                 color = ktcPalette['ktcBlue']) +
      geom_jitter(data = posPos() %>% filter(date == max(date)), aes(x = date, y = value),
                  alpha = 0.3) +
      labs(title = "Player Value Compared to Selected Positions")


  })

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
      geom_line(data = posData, aes(x = date, y = pos_mean)) +
      geom_line(data = posData, aes(x = date, y = pos_max)) +
      labs(title = "Player Value Compared to Position Mean and Max over Time")
    
    ggplotly(pp)

  })
  
  ### PLAYERS TAB ###
  
  # reactive filter for player1 and player2 selections
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
  
  observeEvent(input$debug, {
      browser()
  })
  
  # render plotly dynasty comparison
  output$dynasty_comparison <- renderPlotly({
    
    dc <- player1_dynasty() %>% 
      rbind(player2_dynasty()) %>%
      ggplot(aes(x = date, y = value, color = name)) +
      geom_line() +
      labs(title = "Comparison of Dynasty Values over Time")
    
    ggplotly(dc)
    
    })
  
  output$fantasy_comparison <- renderPlotly({
    
    comp_2020 <- player1_fantasy() %>%
      rbind(player2_fantasy()) %>%
      filter(season == 2020)

    comp_2021 <- player1_fantasy() %>%
      rbind(player2_fantasy()) %>%
      filter(season == 2021)
    # 
    # fc <- ggplot(data = fantasy, aes(x = gameday)) +
    #   geom_line(data = comp_2020, aes(y = fantasy_points_halfppr, color = full_name)) +
    #   geom_line(data = comp_2021, aes(y = fantasy_points_halfppr, color = full_name)) +
    #   xlim(min(dynasty$date), max(dynasty$date)) +
    #   labs(title = "Comparison of Fantasy Performance over Time")
    # 
    # ggplotly(fc)
    
    
    p <- player1_fantasy() %>%
      rbind(player2_fantasy()) %>%
      ggplot(aes(x = gameday, fantasy_points_halfppr, color = full_name, label = paste0(round(fantasy_points_halfppr, 0)))) +
        geom_segment(aes(x = gameday, y = 0, yend = fantasy_points_halfppr, xend = gameday), color = "grey50") +
        geom_point(size = 7) +
        geom_text(color = "white", size = 2) +
        labs(title = "Comparison of Fantasy Performance over Time")
    
    ggplotly(p)
    
  })
  
  output$card1_img <- renderUI({
    
    src <- player1_fantasy() %>%
      filter(season == 2021) %>% 
      select(headshot_url) %>%
      unique()
    
    tags$img(src = src, width = 200, height = 150)
    
  })
  
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
           "<br>Weight: ", dcontent %>% select(Weight) %>% unique())
    
  })
  
  output$card2_img <- renderUI({
    
    src <- player2_fantasy() %>%
      filter(season == 2021) %>% 
      select(headshot_url) %>%
      unique()
    
    tags$img(src = src, width = 200, height = 150)
    
  })
  
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
           "<br>Weight: ", dcontent %>% select(Weight) %>% unique())
    
  })
  
})

