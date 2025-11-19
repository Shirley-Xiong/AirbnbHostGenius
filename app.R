# Airbnb房东数据分析平台 - Shiny应用
# ====================================

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(plotly)
library(DT)

# 加载分析模块
source("R/00_load_data.R")
source("R/01_descriptive_analysis.R")
source("R/02_predictive_models.R")
source("R/03_pricing_engine.R")
source("R/holidays_uk.R")

# ===== 初始化全局数据 =====
message("🚀 启动Airbnb房东数据分析平台...")
message("📦 加载数据和模型...")

csv_path <- "/Users/xiongyi/Desktop/Airbnb/listings (3).csv"
airbnb_data <- load_and_clean_data(csv_path)

message("🔄 训练预测模型...")
train_occupancy_model(airbnb_data)
train_revenue_model(airbnb_data)

# 获取下拉选项
neighbourhoods <- sort(unique(airbnb_data$neighbourhood))
room_types <- sort(unique(airbnb_data$room_type))

message("✓ 平台启动完成！")

# ===== UI定义 =====
ui <- dashboardPage(
  dashboardHeader(
    title = HTML("<i class='fas fa-home'></i> Airbnb房东助手"),
    titleWidth = 300
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem(
        "📊 市场分析",
        tabName = "market_analysis",
        icon = icon("chart-bar")
      ),
      menuItem(
        "🔮 房产工具",
        tabName = "property_tool",
        icon = icon("search")
      ),
      menuItem(
        "💰 定价工具",
        tabName = "pricing_tool",
        icon = icon("tag")
      ),
      hr(),
      p("智能数据分析 & 动态定价", class = "text-muted", 
        style = "padding: 15px; font-size: 12px;")
    )
  ),
  
  dashboardBody(
    # 自定义CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
      tags$style(HTML("
        .stat-box {
          margin-bottom: 20px;
        }
        .info-box {
          margin-bottom: 20px;
        }
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .main-header .navbar {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
      "))
    ),
    
    tabItems(
      # ===== 标签1: 市场分析 =====
      tabItem(
        tabName = "market_analysis",
        
        fluidRow(
          box(
            title = "总房产数",
            uiOutput("stat_total"),
            width = 3,
            status = "primary",
            solidHeader = TRUE
          ),
          box(
            title = "平均价格 (£/晚)",
            uiOutput("stat_avg_price"),
            width = 3,
            status = "success",
            solidHeader = TRUE
          ),
          box(
            title = "平均入住率",
            uiOutput("stat_occupancy"),
            width = 3,
            status = "warning",
            solidHeader = TRUE
          ),
          box(
            title = "平均年收入 (£)",
            uiOutput("stat_revenue"),
            width = 3,
            status = "info",
            solidHeader = TRUE
          )
        ),
        
        fluidRow(
          box(
            title = "房型分布",
            plotlyOutput("room_type_chart"),
            width = 6,
            solidHeader = TRUE,
            status = "primary"
          ),
          box(
            title = "房型收入对比",
            plotlyOutput("revenue_by_type_chart"),
            width = 6,
            solidHeader = TRUE,
            status = "info"
          )
        ),
        
        fluidRow(
          box(
            title = "按地段分析 (前15个)",
            DTOutput("neighbourhood_table"),
            width = 12,
            solidHeader = TRUE,
            status = "primary"
          )
        )
      ),
      
      # ===== 标签2: 房产工具 =====
      tabItem(
        tabName = "property_tool",
        
        fluidRow(
          box(
            title = "预测房产表现",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            
            selectInput(
              "pred_neighbourhood",
              "选择地段 *",
              choices = c("-- 选择地段 --" = "", neighbourhoods),
              width = "100%"
            ),
            
            selectInput(
              "pred_room_type",
              "房型 *",
              choices = c("-- 选择房型 --" = "", room_types),
              width = "100%"
            ),
            
            numericInput(
              "pred_price",
              "每晚价格 (£) *",
              value = 80,
              min = 1,
              width = "100%"
            ),
            
            numericInput(
              "pred_min_nights",
              "最小夜数",
              value = 1,
              min = 1,
              width = "100%"
            ),
            
            numericInput(
              "pred_reviews",
              "现有评论数",
              value = 0,
              min = 0,
              width = "100%"
            ),
            
            numericInput(
              "pred_reviews_per_month",
              "每月评论数",
              value = 0,
              min = 0,
              step = 0.1,
              width = "100%"
            ),
            
            actionButton(
              "pred_button",
              "进行预测",
              class = "btn-success btn-block",
              width = "100%",
              icon = icon("magic")
            )
          ),
          
          box(
            title = "预测结果",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            uiOutput("prediction_result")
          )
        )
      ),
      
      # ===== 标签3: 定价工具 =====
      tabItem(
        tabName = "pricing_tool",
        
        fluidRow(
          box(
            title = "定价建议",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            
            selectInput(
              "price_neighbourhood",
              "选择地段 *",
              choices = c("-- 选择地段 --" = "", neighbourhoods),
              width = "100%"
            ),
            
            selectInput(
              "price_room_type",
              "房型 *",
              choices = c("-- 选择房型 --" = "", room_types),
              width = "100%"
            ),
            
            numericInput(
              "current_price",
              "当前价格 (£/晚) *",
              value = 80,
              min = 1,
              width = "100%"
            ),
            
            sliderInput(
              "occupancy_rate",
              "预测入住率 (%)",
              min = 0,
              max = 100,
              value = 50,
              step = 5,
              width = "100%"
            ),
            
            actionButton(
              "pricing_button",
              "获取定价建议",
              class = "btn-info btn-block",
              width = "100%",
              icon = icon("calculator")
            )
          ),
          
          box(
            title = "定价建议结果",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            uiOutput("pricing_result")
          )
        ),
        
        fluidRow(
          box(
            title = "定价技巧",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            uiOutput("pricing_tips")
          )
        )
      )
    )
  )
)

# ===== Server逻辑 =====
server <- function(input, output, session) {
  
  # 市场概览统计
  market_overview <- reactive({
    get_market_overview(airbnb_data)
  })
  
  output$stat_total <- renderUI({
    h3(
      formatC(market_overview()$total_listings, format = "d", big.mark = ","),
      style = "color: #667eea; font-weight: bold;"
    )
  })
  
  output$stat_avg_price <- renderUI({
    h3(
      glue::glue("£{round(market_overview()$average_price, 2)}"),
      style = "color: #27ae60; font-weight: bold;"
    )
  })
  
  output$stat_occupancy <- renderUI({
    h3(
      glue::glue("{round(market_overview()$average_occupancy_rate * 100, 1)}%"),
      style = "color: #f39c12; font-weight: bold;"
    )
  })
  
  output$stat_revenue <- renderUI({
    h3(
      glue::glue("£{round(market_overview()$average_occupancy_rate * 365 * market_overview()$average_price, 0)}"),
      style = "color: #3498db; font-weight: bold;"
    )
  })
  
  # 房型分布图
  output$room_type_chart <- renderPlotly({
    room_type_data <- analyze_by_room_type(airbnb_data)
    
    df_plot <- bind_rows(lapply(room_type_data, as.data.frame))
    df_plot$room_type <- names(room_type_data)
    
    plot_ly(df_plot, labels = ~room_type, values = ~count, type = "pie") %>%
      layout(
        title = "",
        showlegend = TRUE,
        height = 350
      )
  })
  
  # 房型收入对比
  output$revenue_by_type_chart <- renderPlotly({
    room_type_data <- analyze_by_room_type(airbnb_data)
    
    df_plot <- bind_rows(lapply(room_type_data, as.data.frame))
    df_plot$room_type <- names(room_type_data)
    
    plot_ly(df_plot, x = ~room_type, y = ~avg_estimated_annual_revenue, 
            type = "bar", marker = list(color = "#3498db")) %>%
      layout(
        title = "",
        xaxis = list(title = "房型"),
        yaxis = list(title = "年平均收入 (£)"),
        height = 350
      )
  })
  
  # 地段分析表格
  output$neighbourhood_table <- renderDT({
    neighbourhood_data <- analyze_by_neighbourhood(airbnb_data)
    
    df_table <- bind_rows(lapply(neighbourhood_data, as.data.frame), .id = "neighbourhood") %>%
      select(neighbourhood, listing_count, avg_price, median_price, occupancy_rate, avg_annual_revenue) %>%
      mutate(
        avg_price = round(avg_price, 2),
        median_price = round(median_price, 2),
        occupancy_rate = round(occupancy_rate * 100, 1),
        avg_annual_revenue = round(avg_annual_revenue, 0)
      ) %>%
      rename(
        "地段" = neighbourhood,
        "房产数" = listing_count,
        "平均价格" = avg_price,
        "中位数价格" = median_price,
        "入住率%" = occupancy_rate,
        "年均收入" = avg_annual_revenue
      )
    
    datatable(
      df_table,
      options = list(pageLength = 10, dom = "ltip"),
      rownames = FALSE
    )
  })
  
  # 预测结果
  observeEvent(input$pred_button, {
    
    if (input$pred_neighbourhood == "" || input$pred_room_type == "") {
      showNotification("请选择地段和房型", type = "error")
      return()
    }
    
    property_info <- list(
      price = input$pred_price,
      minimum_nights = input$pred_min_nights,
      number_of_reviews = input$pred_reviews,
      reviews_per_month = input$pred_reviews_per_month,
      room_type = input$pred_room_type,
      neighbourhood = input$pred_neighbourhood
    )
    
    predictions <- predict_with_inputs(property_info)
    
    output$prediction_result <- renderUI({
      tags$div(
        class = "result-box",
        h4("📈 预测结果", style = "color: #667eea;"),
        hr(),
        
        tags$div(
          class = "result-row",
          tags$span("年占用天数:", class = "result-label"),
          tags$span(
            glue::glue("{predictions$occupancy$predicted_occupied_days} 天"),
            class = "result-value"
          )
        ),
        
        tags$div(
          class = "result-row",
          tags$span("占用率区间:", class = "result-label"),
          tags$span(
            glue::glue("{predictions$occupancy$lower_bound} - {predictions$occupancy$upper_bound} 天"),
            class = "result-value"
          )
        ),
        
        hr(),
        
        tags$div(
          class = "result-row",
          tags$span("年收入预测:", class = "result-label"),
          tags$span(
            glue::glue("£{round(predictions$revenue$predicted_annual_revenue, 2)}"),
            class = "result-value positive"
          )
        ),
        
        tags$div(
          class = "result-row",
          tags$span("收入范围:", class = "result-label"),
          tags$span(
            glue::glue("£{round(predictions$revenue$lower_bound, 2)} - £{round(predictions$revenue$upper_bound, 2)}"),
            class = "result-value"
          )
        ),
        
        hr(),
        
        tags$div(
          class = "result-row",
          tags$span("置信度:", class = "result-label"),
          tags$span(
            glue::glue("{predictions$occupancy$confidence * 100}%"),
            style = "color: #f39c12; font-weight: bold;"
          )
        )
      )
    })
  })
  
  # 定价建议结果
  observeEvent(input$pricing_button, {
    
    if (input$price_neighbourhood == "" || input$price_room_type == "") {
      showNotification("请选择地段和房型", type = "error")
      return()
    }
    
    recommendation <- generate_pricing_recommendation(
      airbnb_data,
      neighbourhood = input$price_neighbourhood,
      room_type = input$price_room_type,
      current_price = input$current_price,
      predicted_occupancy_rate = input$occupancy_rate / 100
    )
    
    if (!is.null(recommendation)) {
      output$pricing_result <- renderUI({
        price_change <- recommendation$price_change_from_current
        change_color <- if (price_change$amount >= 0) "#27ae60" else "#e74c3c"
        change_sign <- if (price_change$amount >= 0) "+" else ""
        
        tags$div(
          class = "result-box",
          h4("💰 定价建议", style = "color: #667eea;"),
          hr(),
          
          tags$div(
            class = "result-row",
            tags$span("当前价格:", class = "result-label"),
            tags$span(glue::glue("£{recommendation$current_price}"), class = "result-value")
          ),
          
          tags$div(
            class = "result-row",
            tags$span("市场中位数:", class = "result-label"),
            tags$span(
              glue::glue("£{round(recommendation$base_market_price, 2)}"),
              class = "result-value"
            )
          ),
          
          hr(),
          
          tags$div(
            class = "result-row",
            tags$span("推荐价格:", class = "result-label"),
            tags$span(
              glue::glue("£{recommendation$recommended_price}"),
              style = glue::glue("color: {change_color}; font-weight: bold; font-size: 1.2em;")
            )
          ),
          
          tags$div(
            class = "result-row",
            tags$span("价格变化:", class = "result-label"),
            tags$span(
              glue::glue("{change_sign}£{abs(price_change$amount)} ({change_sign}{price_change$percentage}%)"),
              style = glue::glue("color: {change_color}; font-weight: bold;")
            )
          ),
          
          hr(),
          
          tags$div(
            class = "result-row",
            tags$span("价格范围:", class = "result-label"),
            tags$span(
              glue::glue(
                "£{recommendation$recommended_price_range$conservative} - £{recommendation$recommended_price_range$aggressive}"
              ),
              class = "result-value"
            )
          ),
          
          hr(),
          
          tags$p(
            glue::glue("📊 需求调整: {recommendation$demand_adjustment$reason}"),
            style = "margin-top: 10px; color: #555;"
          )
        )
      })
    } else {
      showNotification("无法生成定价建议", type = "warning")
    }
    
    # 定价技巧
    tips <- get_pricing_tips(airbnb_data, input$price_room_type, input$price_neighbourhood)
    
    output$pricing_tips <- renderUI({
      tip_items <- lapply(tips, function(tip) {
        tags$li(tip, style = "margin-bottom: 10px;")
      })
      
      tags$ul(
        tip_items,
        style = "list-style-type: none; padding-left: 0;"
      )
    })
  })
}

# 运行应用
shinyApp(ui, server)


