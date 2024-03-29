#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(heatmaply)
library(dplyr)
library(plotly)
library(readr)
library(corrplot)
library(ggstatsplot)
library(tidyr)
library(dtwclust)
library(dtw)
library(cluster)
        

# data preperation
bmi <- read_csv("data/bmi_data.csv")

# aggregate_data
aggregate_data <- function(data, agg_method, group_level) {
  
  agg_funcs <- list(
    mean = mean,
    max = max,
    min = min,
    median = median,
    var = var
  )
  
  aggregated_data <- data %>%
    group_by(.data[[group_level]]) %>%
    summarise(
      bmi_localprice = agg_funcs[[agg_method]](bmi_localprice, na.rm = TRUE),
      bmi_usd_price = agg_funcs[[agg_method]](bmi_usd_price, na.rm = TRUE),
      bmi_change = agg_funcs[[agg_method]](bmi_change, na.rm = TRUE),
      export_usd = agg_funcs[[agg_method]](export_usd, na.rm = TRUE),
      import_usd = agg_funcs[[agg_method]](import_usd, na.rm = TRUE),
      net_export = agg_funcs[[agg_method]](net_export, na.rm = TRUE),
      GDP = agg_funcs[[agg_method]](GDP, na.rm = TRUE),
      gdp_per_capita = agg_funcs[[agg_method]](gdp_per_capita, na.rm = TRUE),
      inflation = agg_funcs[[agg_method]](inflation, na.rm = TRUE),
      unemployment = agg_funcs[[agg_method]](unemployment, na.rm = TRUE),
      hdi = agg_funcs[[agg_method]](hdi, na.rm = TRUE),
      population = agg_funcs[[agg_method]](population, na.rm = TRUE)
    )
  
  return(aggregated_data)
}

## get numeric data for corr
bmi_numeric <- bmi %>%
  select(country, where(is.numeric))



# feature eng for tsclustering
# drop missing values
bmi_clean <- bmi %>%
  filter(complete.cases(.))

# 1. Select relevant columns
bmi_filtered <- select(bmi_clean, -currency_code)

# 2. Convert to a wide format, prepare for conversion to list of matrices
bmi_wide <- bmi_filtered %>%
  pivot_longer(cols = -c(country, year), names_to = "variable", values_to = "value") %>%
  pivot_wider(names_from = variable, values_from = value, names_sort = TRUE) %>%
  arrange(country, year)


# Group by country and convert each group to a matrix
list_matrices_per_country <- bmi_wide %>%
  group_by(country) %>%
  group_split() %>%
  lapply(function(df) {
    # Ensure year is not included in the matrix
    df <- select(df, -country, -year)
    as.matrix(df)
  })





# Define server logic required to draw a histogram
function(input, output, session) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')

    })
    
    
    
    # heatmap
    output$heatmapPlot <- renderPlotly({
      # create an aggregated dataframe
      bmi_heatmap <- aggregate_data(bmi, input$hm_agg, input$hm_compare)
      
      # convert to a matrix
      row.names(bmi_heatmap) <- bmi_heatmap$country
      bmi_heatmap_matrix <- data.matrix(bmi_heatmap)
      
      # Generate heatmap
      heatmaply(normalize(bmi_heatmap_matrix), dendrogram = input$hm_den)
    })
    
    
    
    # corrplot
    output$corrPlot <- renderPlot({
      # get cor matrix
      bmi.cor <- cor(bmi_numeric[-1],method = input$mt_cr_test,use = "complete.obs")
      corrplot(bmi.cor,
               diag = FALSE,
               tl.col = "black",
               method = 'square',
               order = 'hclust'
               )
    })
    
    # tscluster
    output$tscPlot <- renderPlot({
      # cluster
      clustering_result <- tsclust(list_matrices_per_country, type = input$c_tsc_type, k = 4, distance = "dtw")
      
      cluster_assignments <- clustering_result@cluster
      
      country_names <- bmi_wide$country %>% unique()
      
      if(length(country_names) == length(cluster_assignments)) {
        country_cluster_df <- data.frame(country = country_names, cluster = cluster_assignments)
      } else {
        stop("Mismatch between the number of countries and the number of cluster assignments.")
      }
      
      root_node <- data.frame(cluster = unique(country_cluster_df$cluster))
      
      edges_cluster_country <- country_cluster_df %>%
        select(cluster, country) %>%
        rename(from = cluster, to = country)
      
      edges_root_cluster <- data.frame(from = "", to = root_node$cluster)
      
      edge_list <- rbind(edges_root_cluster, edges_cluster_country)
      
      mygraph <- graph_from_data_frame(edge_list)
      
      # Plot
      ggraph(mygraph, layout = 'dendrogram', circular = FALSE) + 
        geom_edge_diagonal() +
        geom_node_point(color="#ffcc00", size=3) +
        geom_node_text(aes(label=name), hjust="inward", nudge_y=0.5) +
        theme_void() +
        coord_flip() +
        scale_y_reverse()
      
      
      
    })
    
    

}


