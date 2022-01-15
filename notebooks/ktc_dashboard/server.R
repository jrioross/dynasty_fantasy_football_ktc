shinyServer(function(input, output) {
  
  ### ATTRIBUTES TAB ###
  

  
  ### POSITIONS TAB ###
  
  # HMDA data filter 1 for compare tab
  # compare_filter_1 <- callModule(
  #   shiny_data_filter,
  #   "compare_filter_1",
  #   data = hmda_data,
  #   verbose = FALSE)
  
  
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
  
  output$card1_img <- renderImage({
    
    img <- player1_fantasy() %>%
      filter(season == 2020) %>% 
      select(headshot_url) %>%
      unique()
    img(src = img)
    #img(img)
    
  })
  
  output$card1_text <- renderText({
    
    fcontent <- player1_fantasy() %>% 
      filter(gameday == max(gameday))
    
    dcontent <- player1_dynasty() %>%
      filter(date == max(date))
    
    paste0("<b>Name: ", input$player1, "</b>",
           "<br>Position: ", dcontent %>% select(Position),
           "<br>Team: ", fcontent %>% select(recent_team),
           "<br>Age: ", dcontent %>% select(Age),
           "<br>Experience: ", dcontent %>% select(Experience),
           "<br>Height: ", dcontent %>% select(Height),
           "<br>Weight: ", dcontent %>% select(Weight))
    
  })
  
})

