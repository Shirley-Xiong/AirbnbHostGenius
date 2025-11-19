# 数据加载和清洗模块
# ====================================

library(tidyverse)
library(data.table)
library(readr)

#' 加载和清洗Airbnb数据
#'
#' @param csv_path CSV文件路径
#' @return 清洗后的数据框
#'
load_and_clean_data <- function(csv_path) {
  
  message("🔄 加载数据中...")
  
  # 加载数据
  df <- read_csv(csv_path, show_col_types = FALSE)
  
  message(glue::glue("✓ 成功加载数据: {nrow(df)} 条记录"))
  message(glue::glue("✓ 列: {paste(names(df), collapse = ', ')}"))
  
  # 数据清洗
  message("\n🔄 清洗数据中...")
  
  df_clean <- df %>%
    # 1. 移除重复记录
    distinct(id, .keep_all = TRUE) %>%
    
    # 2. 处理缺失值
    mutate(
      reviews_per_month = replace_na(reviews_per_month, 0),
      number_of_reviews_ltm = replace_na(number_of_reviews_ltm, 0),
      last_review = lubridate::ymd(last_review),
      neighbourhood = replace_na(neighbourhood, "Unknown")
    ) %>%
    
    # 3. 转换数据类型
    mutate(
      price = as.numeric(gsub("[£,]", "", price)),
      minimum_nights = as.numeric(minimum_nights),
      availability_365 = as.numeric(availability_365)
    ) %>%
    
    # 4. 移除无效数据
    filter(
      !is.na(price),
      !is.na(minimum_nights),
      !is.na(availability_365),
      !is.na(room_type),
      price > 0,
      minimum_nights >= 0
    )
  
  message(glue::glue("✓ 清洗后: {nrow(df_clean)} 条有效记录"))
  
  # 5. 计算关键指标
  df_clean <- df_clean %>%
    mutate(
      occupancy_rate = (365 - availability_365) / 365,
      occupancy_rate = pmax(0, pmin(1, occupancy_rate)),  # 限制在0-1之间
      annual_occupied_days = 365 * occupancy_rate,
      estimated_annual_revenue = price * annual_occupied_days
    )
  
  return(df_clean)
}

#' 获取数据摘要统计
#'
#' @param df 数据框
#' @return 包含统计信息的列表
#'
get_summary_stats <- function(df) {
  
  summary <- list(
    total_listings = nrow(df),
    avg_price = mean(df$price, na.rm = TRUE),
    median_price = median(df$price, na.rm = TRUE),
    price_std = sd(df$price, na.rm = TRUE),
    avg_occupancy_rate = mean(df$occupancy_rate, na.rm = TRUE),
    avg_reviews_per_month = mean(df$reviews_per_month, na.rm = TRUE),
    room_types = df %>%
      group_by(room_type) %>%
      summarise(count = n(), .groups = 'drop') %>%
      deframe(),
    neighbourhoods = n_distinct(df$neighbourhood),
    avg_estimated_annual_revenue = mean(df$estimated_annual_revenue, na.rm = TRUE)
  )
  
  return(summary)
}

#' 获取处理后的数据
#'
#' @return 全局环境中的处理数据（如果存在）
#'
get_processed_data <- function() {
  if (exists("airbnb_data", envir = .GlobalEnv)) {
    return(get("airbnb_data", envir = .GlobalEnv))
  } else {
    return(NULL)
  }
}

# 测试运行
if (FALSE) {  # 设置为TRUE进行测试
  csv_path <- "/Users/xiongyi/Desktop/Airbnb/listings (3).csv"
  df <- load_and_clean_data(csv_path)
  
  message("\n📊 数据摘要:")
  stats <- get_summary_stats(df)
  str(stats)
}


