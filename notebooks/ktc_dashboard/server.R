shinyServer(function(input, output) {
  
  ### ATTRIBUTES TAB ###
  
  # Filter census data based on scope
  my_sf <- reactive({
    census_data %>%
      filter(scope == rv$scope)
  })
  
  # HMDA data filter for visualize tab
  visualize_filter <- callModule(
    shiny_data_filter,
    "visualize_filter",
    data = hmda_data,
    verbose = FALSE)
  
  # Toggle filter panel based on filter button click
  observeEvent(input$filterButton, {
    toggle('filterPanel')
  })
  
  observeEvent(input$mymap_shape_click, { 
    showModal(modalDialog(
      plotlyOutput("census_plot_race"),
      title = input$mymap_shape_click[1],
      fade = F,
      easyClose = T,
      footer = NULL
    ))
  })
  
  output$census_plot_race <- renderPlotly({
    a <- census_data %>%
      filter(NAME == input$mymap_shape_click[1]) %>%
      select(NAME, white, black, `american indian`, asian, `pacific islander`, `other race`, `two or more races`) %>%
      pivot_longer(!NAME, names_to = "Race", values_to = "Population")
    
    b <- hmda_census_race_data %>%
      filter(NAME == input$mymap_shape_click[1]) %>%
      count(NAME, Race) %>%
      rename(Population = n)
    
    ab <- rbind(a %>% mutate(Group = "census"),
                b %>% mutate(Group = "hmda")) %>%
      group_by(Group, NAME) %>%
      mutate(Proportion = Population/sum(Population))
    
    p <- ggplot(data = ab, aes(x = str_wrap(Race, width = 10), 
                               y = Proportion, 
                               fill = Group,
                               text = sprintf("Group: %s<br>Race: %s<br>Percent: %s",
                                              Group, 
                                              Race, 
                                              scales::percent(Proportion, scale = 100, accuracy = 0.01)
                               )
    )
    ) +
      geom_col(position = 'dodge') +
      scale_x_discrete(limits = rev) +
      scale_y_continuous(labels = scales::percent) +
      labs(title = "Proportion of Applicant Race by Comparison Group",
           x = "Race")
    ggplotly(p, tooltip = 'text')
    
  })
  
  ### POSITIONS TAB ###
  
  # HMDA data filter 1 for compare tab
  compare_filter_1 <- callModule(
    shiny_data_filter,
    "compare_filter_1",
    data = hmda_data,
    verbose = FALSE)
  
  # HMDA data filter 2 for compare tab
  compare_filter_2 <- callModule(
    shiny_data_filter,
    "compare_filter_2",
    data = hmda_data,
    verbose = FALSE)
  
  observeEvent(input$go, {
    # Boxplots of Loan Amounts by Filter Group
    output$plot_amounts <- renderPlotly({
      isolate(
        p2 <- ggplot() +
          geom_boxplot(data = compare_filter_1(), aes(x = "Group 1", y = `Loan Amount`, color = "Group 1")) +
          geom_boxplot(data = compare_filter_2() %>% setdiff(compare_filter_1()), aes(x = "Group 2", y = `Loan Amount`, color = "Group 2")) +
          scale_y_log10() +
          labs(title = "Boxplot of Comparison Group Loan Amounts",
               x = "Comparison Group")
      )
      ggplotly(p2)
    })
    # Proportions of Actions Taken by Filter Group
    output$plot_action <- renderPlotly({
      isolate(
        data <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                      compare_filter_2() %>% setdiff(compare_filter_1()) %>% mutate(Group = "Group 2")) %>%
          count(Group, `Action Taken`) %>%
          group_by(Group) %>%
          mutate(Proportion = n/sum(n))
      )
      p <- ggplot(data = data, aes(x = str_wrap(`Action Taken`, width = 12), 
                                   y = Proportion, 
                                   fill = Group, 
                                   text = sprintf("Group: %s<br>Action Taken: %s<br>Percent: %s",
                                                  Group, 
                                                  `Action Taken`, 
                                                  scales::percent(Proportion, scale = 100, accuracy = 0.01)
                                   )
      )
      )+
        geom_col(position = 'dodge')+
        scale_y_continuous(labels = scales::percent) +
        theme(legend.position = "right") +
        labs(title = "Proportion of Action Taken by Comparison Group",
             x = "Action Taken")
      
      ggplotly(p, height = 600, tooltip = 'text')
    })
    # Proportions of Applicant Race by Filter Group
    output$plot_race <- renderPlotly({
      isolate(
        data <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                      compare_filter_2() %>% setdiff(compare_filter_1()) %>% mutate(Group = "Group 2")) %>%
          filter(Race != "Free Form Text Only") %>%
          count(Group, Race) %>%
          group_by(Group) %>%
          mutate(Proportion = n/sum(n))
      )
      p <- ggplot(data = data, aes(x = str_wrap(Race, width = 17), 
                                   y = Proportion, 
                                   fill = Group,
                                   text = sprintf("Group: %s<br>Race: %s<br>Percent: %s",
                                                  Group, 
                                                  Race, 
                                                  scales::percent(Proportion, scale = 100, accuracy = 0.01)
                                   )
      )
      ) +
        geom_col(position = 'dodge') +
        scale_x_discrete(limits = rev) +
        scale_y_continuous(labels = scales::percent) +
        labs(title = "Proportion of Applicant Race by Comparison Group",
             x = "Race")
      figr <- ggplotly(p, tooltip = 'text') %>% layout(legend = list(orientation = "h", xanchor = "right", yanchor = "top", x = 1, y = 1))
    })
    # Proportions of Applicant Ethnicity by Filter Group
    output$plot_ethnicity <- renderPlotly({
      isolate(
        data <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                      compare_filter_2() %>% setdiff(compare_filter_1()) %>% mutate(Group = "Group 2")) %>%
          filter(Ethnicity != "Free Form Text Only") %>%
          count(Group, Ethnicity) %>%
          group_by(Group) %>%
          mutate(Proportion = n/sum(n))
      )
      p <- ggplot(data = data, aes(x = Ethnicity, 
                                   y = Proportion, 
                                   fill = Group,
                                   text = sprintf("Group: %s<br>Ethnicity: %s<br>Percent: %s",
                                                  Group, 
                                                  Ethnicity, 
                                                  scales::percent(Proportion, scale = 100, accuracy = 0.01)
                                   )
      )
      ) +
        geom_col(position = 'dodge') +
        scale_x_discrete(limits = rev) +
        scale_y_continuous(labels = scales::percent) +
        theme(legend.position = "none") +
        labs(title = "Proportion of Applicant Ethnicity by Comparison Group")
      fige <- ggplotly(p, tooltip = 'text')
    })
    # Proportions of Applicant Sex by Filter Group
    output$plot_sex <- renderPlotly({
      isolate(
        data <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                      compare_filter_2() %>% setdiff(compare_filter_1()) %>% mutate(Group = "Group 2")) %>%
          count(Group, Sex) %>%
          group_by(Group) %>%
          mutate(Proportion = n/sum(n))
      )
      p <- ggplot(data = data, aes(x = Sex, 
                                   y = Proportion, 
                                   fill = Group,
                                   text = sprintf("Group: %s<br>Sex: %s<br>Percent: %s",
                                                  Group, 
                                                  Sex, 
                                                  scales::percent(Proportion, scale = 100, accuracy = 0.01)
                                   )
      )
      ) +
        geom_col(position = 'dodge') +
        scale_y_continuous(labels = scales::percent) +
        theme(legend.position = "none") +
        labs(title = "Proportion of Applicant Sex by Comparison Group")
      figs <- ggplotly(p, tooltip = 'text')
    })
    # Proportions of Applicant Age by Filter Group
    output$plot_age <- renderPlotly({
      isolate(
        data <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                      compare_filter_2() %>% setdiff(compare_filter_1()) %>% mutate(Group = "Group 2")) %>%
          count(Group, `Applicant Age`) %>%
          group_by(Group) %>%
          mutate(Proportion = n/sum(n))
      )
      p <- ggplot(data = data, aes(x = `Applicant Age`, 
                                   y = Proportion, 
                                   fill = Group,
                                   text = sprintf("Group: %s<br>Applicant Age: %s<br>Percent: %s",
                                                  Group, 
                                                  `Applicant Age`, 
                                                  scales::percent(Proportion, scale = 100, accuracy = 0.01)
                                   )
      )
      ) +
        geom_col(position = 'dodge') +
        scale_y_continuous(labels = scales::percent) +
        theme(legend.position = "none") +
        labs(title = "Proportion of Applicant Age by Comparison Group")
      figa <- ggplotly(p, tooltip = 'text')
    })
    # Proportions of Denial Reasons by Filter Group
    output$plot_denial <- renderPlotly({
      isolate(
        data <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                      compare_filter_2() %>% setdiff(compare_filter_1()) %>% mutate(Group = "Group 2")) %>%
          count(Group, `Denial Reason #1`) %>%
          group_by(Group) %>%
          mutate(Proportion = n/sum(n))
      )
      p <- ggplot(data = data, aes(x = str_wrap(`Denial Reason #1`, width = 10), 
                                   y = Proportion, 
                                   fill = Group, 
                                   text = sprintf("Group: %s<br>Denial Reason: %s<br>Percent: %s",
                                                  Group, 
                                                  `Denial Reason #1`, 
                                                  scales::percent(Proportion, scale = 100, accuracy = 0.01)
                                   )
      )
      )+
        geom_col(position = 'dodge')+
        scale_y_continuous(labels = scales::percent) +
        theme(legend.position = "right") +
        labs(title = "Proportion of Denial Reason by Comparison Group",
             x = "Denial Reason")
      
      ggplotly(p, height = 600, tooltip = 'text')
    })
  })
  
  ### PLAYERS TAB ###
  
  # reactive filter for player1 and player2 selections
  player12_dynasty <- reactive({
    dynasty %>%
      filter(name %in% c(input$player1, input$player2))
  })
  
  # render plotly dynasty comparison
  output$dynasty_comparison <- renderPlotly({
    
    dc <- player12_dynasty() %>% 
      ggplot(aes(x = date, y = value, color = name)) +
      geom_line()
    
    ggplotly(dc)
    
    })
  
    })
})
