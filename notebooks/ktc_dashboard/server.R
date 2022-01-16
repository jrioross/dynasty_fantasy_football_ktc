shinyServer(function(input, output) {
  
  ### ATTRIBUTES TAB ###
  
  attrPos <- reactive({
    
    dynasty %>%
      filter(Position %in% input$attrPosSelection,
             date == max(date))
      
  })
  
  output$corrGraph <- renderPlotly({
    
    dyCorr <- attrPos() %>%
      select(-name, -Drafted, -College, -date, -Born, -Position) %>%
      cor(use = "pairwise.complete.obs")
    
    p.mat <- attrPos() %>%
      select(-name, -Drafted, -College, -date, -Born, -Position) %>%
      ggcorrplot::cor_pmat()
    
    p <- ggcorrplot(dyCorr,
               hc.order = TRUE,
               type = "upper",
               p.mat = p.mat,
               colors = c("#E85262", "white", "#136C9D"),
               ggtheme = theme_dark)
    
    ggplotly(p)
    
  })
  
  output$attrScatter <- renderPlotly({
    
    val_draft <- dynasty %>% 
      group_by(name) %>% 
      filter(date == max(date)) %>%
      drop_na(Position) %>%
      ggplot(aes(x = `Draft Overall Pick`, 
                 y = value, 
                 color = Position,
      )) +
      geom_point(aes(text = sprintf("Name: %s<br>Draft Position: %s<br>Value: %s<br>Position: %s",
                                    name, `Draft Overall Pick`, value, Position
      ))) +
      geom_smooth(se = FALSE) +
      facet_wrap(~Position)
    
    ggplotly(val_draft, tooltip = 'text')
    
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
        geom_boxplot()
    
    ggplotly(vals_by_position)
    
  })
  
  output$posScatter <- renderPlotly({
    

    ggplot() +
      geom_point(data = posPlayer()%>% filter(date == max(date)), aes(x = date, y = value),
                 color = ktcPalette['ktcBlue']) +
      geom_jitter(data = posPos() %>% filter(date == max(date)), aes(x = date, y = value),
                  alpha = 0.3) 


  })

  output$playerVposition <- renderPlot({

      #transition_reveal(gameday)
    
    ggplot() +
      geom_line(data = posPlayer(), aes(x = date, y = value), color = "red")+
      geom_line(data = posDynasty(), aes(x = date, y = pos_mean)) +
      geom_line(data = posDynasty(), aes(x = date, y = pos_max))

  })
  
  ### PLAYERS TAB ###
  
  # reactive filter for player1 and player2 selections
  player1_dynasty <- reactive({
    dynasty %>%
      filter(name == input$player1)
  })
  
  player2_dynasty <- reactive({
    dynasty %>%
      filter(name == input$player2)
  })
  
  player1_fantasy <- reactive({
    fantasy %>%
      filter(full_name == input$player1)
  })
  
  player2_fantasy <- reactive({
    fantasy %>%
      filter(full_name == input$player2)
  })
  
  observeEvent(input$debug, {
      browser()
  })
  
  # render plotly dynasty comparison
  output$dynasty_comparison <- renderPlotly({
    
    dc <- player1_dynasty() %>% 
      rbind(player2_dynasty()) %>%
      ggplot(aes(x = date, y = value, color = name)) +
      geom_line()
    
    ggplotly(dc)
    
    })
  
  output$fantasy_comparison <- renderPlotly({
    
    comp_2020 <- player1_fantasy() %>% 
      rbind(player2_fantasy()) %>%
      filter(season == 2020) 
    
    comp_2021 <- player1_fantasy() %>% 
      rbind(player2_fantasy()) %>%
      filter(season == 2021) 
    
    fc <- ggplot(data = fantasy, aes(x = gameday)) +
      geom_line(data = comp_2020, aes(y = fantasy_points_halfppr, color = full_name)) +
      geom_line(data = comp_2021, aes(y = fantasy_points_halfppr, color = full_name)) +
      xlim(min(dynasty$date), max(dynasty$date))
    
    ggplotly(fc)
    
  })
  
  output$card1_img <- renderUI({
    
    src <- player1_fantasy() %>%
      filter(season == 2020) %>% 
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
      filter(season == 2020) %>% 
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

