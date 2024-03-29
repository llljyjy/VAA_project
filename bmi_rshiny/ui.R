#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinythemes)
library(shinydashboard)

# Define UI for the dashboard

ui <- dashboardPage(
  dashboardHeader(title = "LOGO"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Time Series Analysis", tabName = "ts-a", icon = icon("file")),
      menuItem("Multi-Variant heatmap", tabName = "heatmap", icon = icon("file")),
      menuItem("Multi-Variant corrplot", tabName = "corrplot", icon = icon("file")),
      menuItem("Clustering", tabName = "cl", icon = icon("file")),
      menuItem("Prediction", tabName = "pr", icon = icon("file"))
    )
  ),
  dashboardBody(
    # Custom styles for navbar and main panel
    tags$head(
      
      # tags$style(HTML("
      #  
      #   .skin-blue .main-header .navbar {
      #     background-color: #FFCC00 ;
      #   }
      #   
      #   .skin-blue .main-sidebar {
      #     background-color: #00000 ;
      #   }
      #   
      #   .content-wrapper, .right-side {
      #     background-color: #FFFFFF ;
      #   }
      # "))
      
    ),
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                titlePanel("Old Faithful Geyser Data"),
                sidebarLayout(
                  sidebarPanel(
                    sliderInput("bins", "Number of bins:", min = 1, max = 50, value = 30)
                  ),
                  mainPanel(
                    plotOutput("distPlot")
                  )
                )
              )
      ),
      
      tabItem(tabName = "ts-a",
              # Add content for the "Reports" tab here
      ),
      tabItem(tabName = "heatmap",
            
              # heatmap
              fluidRow(
                titlePanel("Heatmap"),
                sidebarLayout(
                  
                  sidebarPanel(
                    
                    # Copy the line below to make a set of radio buttons
                    radioButtons("hm_compare", label = h3("Compare Across"),
                                 choices = list("By Country" = 'country', "By Year" = 'year'), 
                                 selected = 'country'),
                    
                    # Copy the line below to make a select box 
                    selectInput("hm_agg", label = h3("AGGREGATION LEVEL"), 
                                choices = list("Mean" = "mean", "Median" = "median", "Max" = "max", "Min" = "min", "Var" = "var"), 
                                selected = "mean"),
                    
                    # Copy the line below to make a set of radio buttons
                    radioButtons("hm_trans", label = h3("Data Transformation"),
                                 choices = list("Normalization" = 'normalize', "Scaling" = 'scale', 'Percentile' = 'percentize'), 
                                 selected = 'percentize'),
                    
                    # Copy the line below to make a checkbox
                    checkboxInput("hm_den", label = "Dendrogram", value = TRUE)
                    
                  ),
                  
                  mainPanel(
                    plotlyOutput("heatmapPlot")
                  )
                )
              )
      
      ),
      
      
      
      tabItem(tabName = "corrplot",
              
              # corrplot
              fluidRow(
                titlePanel("Corrplot"),
                sidebarLayout(
                  
                  sidebarPanel(
                    
                    # Copy the line below to make a set of radio buttons
                    radioButtons("mt_cr_test", label = h3("Test Method"),
                                 choices = list("Pearson" = 'pearson', "Kendall" = 'kendall', 'Spearman'='spearman'), 
                                 selected = 'pearson'),
  
                    
                  ),
                  
                  mainPanel(
                    plotOutput("corrPlot")
                  )
                )
              )
      ),
      tabItem(tabName = "cl",
              # Add content for the "Reports" tab here
              
              # tscluster
              fluidRow(
                titlePanel("TS Cluster"),
                sidebarLayout(
                  
                  sidebarPanel(
                    
                    # Copy the line below to make a set of radio buttons
                    radioButtons("c_tsc_type", label = h3("Clustering Method"),
                                 choices = list("Hierarchical" = 'hierarchical', "Partitional" = 'partitional'), 
                                 selected = 'hierarchical'),
                    
                    
                  ),
                  
                  mainPanel(
                    plotOutput("tscPlot")
                  )
                )
              )
              
              
              
              
      ),
      tabItem(tabName = "pr",
              # Add content for the "Reports" tab here
      )
      
    )
  )
)
