# 描述性分析模块
# ====================================

library(tidyverse)
library(data.table)

#' 获取市场概览
#'
#' @param df 数据框
#' @return 市场概览列表
#'
get_market_overview <- function(df) {
  
  overview <- list(
    total_listings = nrow(df),
    average_price = mean(df$price, na.rm = TRUE),
    median_price = median(df$price, na.rm = TRUE),
    price_range = list(
      min = min(df$price, na.rm = TRUE),
      max = max(df$price, na.rm = TRUE)
    ),
    average_occupancy_rate = mean(df$occupancy_rate, na.rm = TRUE),
    total_neighbourhoods = n_distinct(df$neighbourhood),
    average_reviews_per_month = mean(df$reviews_per_month, na.rm = TRUE)
  )
  
  return(overview)
}

#' 按房型分析
#'
#' @param df 数据框
#' @return 房型分析结果
#'
analyze_by_room_type <- function(df) {
  
  analysis <- df %>%
    group_by(room_type) %>%
    summarise(
      count = n(),
      avg_price = mean(price, na.rm = TRUE),
      median_price = median(price, na.rm = TRUE),
      avg_occupancy_rate = mean(occupancy_rate, na.rm = TRUE),
      avg_reviews_per_month = mean(reviews_per_month, na.rm = TRUE),
      avg_estimated_annual_revenue = mean(estimated_annual_revenue, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    mutate(market_share = count / sum(count))
  
  return(as.list(split(analysis, seq(nrow(analysis)))) %>%
           setNames(analysis$room_type))
}

#' 按地段分析 - 前20个地段
#'
#' @param df 数据框
#' @return 地段分析结果
#'
analyze_by_neighbourhood <- function(df) {
  
  neighbourhood_stats <- df %>%
    group_by(neighbourhood) %>%
    summarise(
      listing_count = n(),
      avg_price = mean(price, na.rm = TRUE),
      median_price = median(price, na.rm = TRUE),
      price_std = sd(price, na.rm = TRUE),
      occupancy_rate = mean(occupancy_rate, na.rm = TRUE),
      reviews_per_month = mean(reviews_per_month, na.rm = TRUE),
      avg_annual_revenue = mean(estimated_annual_revenue, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    arrange(desc(listing_count)) %>%
    head(20)
  
  # 转换为列表格式
  result <- split(neighbourhood_stats, seq(nrow(neighbourhood_stats))) %>%
    setNames(neighbourhood_stats$neighbourhood)
  
  return(result)
}

#' 获取价格分布统计
#'
#' @param df 数据框
#' @return 百分比统计
#'
get_price_distribution_stats <- function(df) {
  
  percentiles <- c(10, 25, 50, 75, 90)
  
  stats <- list(
    percentiles = as.list(
      setNames(
        quantile(df$price, probs = percentiles / 100, na.rm = TRUE),
        paste0("p", percentiles)
      )
    ),
    by_room_type = {}
  )
  
  # 按房型统计
  for (room_type in unique(df$room_type)) {
    room_df <- df %>% filter(room_type == !!room_type)
    stats$by_room_type[[room_type]] <- 
      as.list(setNames(
        quantile(room_df$price, probs = percentiles / 100, na.rm = TRUE),
        paste0("p", percentiles)
      ))
  }
  
  return(stats)
}

#' 找到相似的房产
#'
#' @param df 数据框
#' @param neighbourhood 地段
#' @param room_type 房型
#' @param price_tolerance 价格容差
#' @return 相似房产统计
#'
find_similar_properties <- function(df, neighbourhood, room_type, price_tolerance = 0.2) {
  
  similar_df <- df %>%
    filter(
      neighbourhood == !!neighbourhood,
      room_type == !!room_type
    )
  
  if (nrow(similar_df) == 0) {
    return(NULL)
  }
  
  stats <- list(
    count = nrow(similar_df),
    avg_price = mean(similar_df$price, na.rm = TRUE),
    median_price = median(similar_df$price, na.rm = TRUE),
    min_price = min(similar_df$price, na.rm = TRUE),
    max_price = max(similar_df$price, na.rm = TRUE),
    price_std = sd(similar_df$price, na.rm = TRUE),
    avg_occupancy_rate = mean(similar_df$occupancy_rate, na.rm = TRUE),
    median_occupancy_rate = median(similar_df$occupancy_rate, na.rm = TRUE),
    avg_reviews_per_month = mean(similar_df$reviews_per_month, na.rm = TRUE),
    avg_annual_revenue = mean(similar_df$estimated_annual_revenue, na.rm = TRUE),
    median_annual_revenue = median(similar_df$estimated_annual_revenue, na.rm = TRUE)
  )
  
  return(stats)
}

#' 获取收入最高的地段
#'
#' @param df 数据框
#' @param limit 返回数量
#' @return 收入排名
#'
get_top_neighbourhoods_by_revenue <- function(df, limit = 10) {
  
  neighbourhood_revenue <- df %>%
    group_by(neighbourhood) %>%
    summarise(
      avg_revenue = mean(estimated_annual_revenue, na.rm = TRUE),
      median_revenue = median(estimated_annual_revenue, na.rm = TRUE),
      listing_count = n(),
      avg_price = mean(price, na.rm = TRUE),
      occupancy_rate = mean(occupancy_rate, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    arrange(desc(avg_revenue)) %>%
    head(limit)
  
  # 转换为列表
  result <- split(neighbourhood_revenue, seq(nrow(neighbourhood_revenue))) %>%
    setNames(neighbourhood_revenue$neighbourhood)
  
  return(result)
}

#' 比较不同房型的表现
#'
#' @param df 数据框
#' @return 房型对比
#'
get_room_type_comparison <- function(df) {
  
  comparison <- df %>%
    group_by(room_type) %>%
    summarise(
      listings = n(),
      market_share_pct = round(n() / nrow(df) * 100, 1),
      avg_price = mean(price, na.rm = TRUE),
      median_price = median(price, na.rm = TRUE),
      occupancy_rate = mean(occupancy_rate, na.rm = TRUE),
      avg_revenue = mean(estimated_annual_revenue, na.rm = TRUE),
      median_revenue = median(estimated_annual_revenue, na.rm = TRUE),
      .groups = 'drop'
    )
  
  return(comparison)
}

#' 生成完整的市场报告
#'
#' @param df 数据框
#' @return 完整报告列表
#'
generate_market_report <- function(df) {
  
  report <- list(
    market_overview = get_market_overview(df),
    by_room_type = analyze_by_room_type(df),
    top_neighbourhoods = analyze_by_neighbourhood(df),
    price_distribution = get_price_distribution_stats(df),
    top_revenue_neighbourhoods = get_top_neighbourhoods_by_revenue(df),
    room_type_comparison = get_room_type_comparison(df)
  )
  
  return(report)
}


