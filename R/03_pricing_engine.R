# 定价引擎模块 - 智能动态定价建议
# ====================================

library(tidyverse)
library(lubridate)
library(holidays)

#' 获取基础价格（市场中位数）
#'
#' @param df 数据框
#' @param neighbourhood 地段
#' @param room_type 房型
#' @return 基础定价信息
#'
get_base_price <- function(df, neighbourhood, room_type) {
  
  similar <- df %>%
    filter(
      neighbourhood == !!neighbourhood,
      room_type == !!room_type
    )
  
  if (nrow(similar) == 0) {
    return(NULL)
  }
  
  base_price <- median(similar$price, na.rm = TRUE)
  avg_price <- mean(similar$price, na.rm = TRUE)
  price_std <- sd(similar$price, na.rm = TRUE)
  percentile_25 <- quantile(similar$price, 0.25, na.rm = TRUE)
  percentile_75 <- quantile(similar$price, 0.75, na.rm = TRUE)
  
  return(list(
    base_price = as.numeric(base_price),
    average_price = as.numeric(avg_price),
    price_std = as.numeric(price_std),
    price_25_percentile = as.numeric(percentile_25),
    price_75_percentile = as.numeric(percentile_75),
    comparable_listings = nrow(similar),
    avg_occupancy_rate = mean(similar$occupancy_rate, na.rm = TRUE)
  ))
}

#' 计算季节性价格乘数
#'
#' @param date 日期（默认为当前日期）
#' @return 价格乘数 (0.8 - 1.3)
#'
calculate_seasonal_multiplier <- function(date = Sys.Date()) {
  
  month <- month(date)
  
  # 伦敦高峰期: 5-9月
  # 淡季: 1月, 11-12月
  # 中等: 其他
  
  multiplier <- case_when(
    month %in% c(7, 8) ~ 1.30,     # 暑假高峰
    month %in% c(5, 6, 9) ~ 1.20,  # 春夏秋季
    month %in% c(2, 3, 4, 10) ~ 1.0,  # 平季
    month %in% c(1, 11) ~ 0.85,    # 冬季
    month == 12 ~ 1.25             # 圣诞节高峰
  )
  
  return(multiplier)
}

#' 检查是否是节假日
#'
#' @param date 日期
#' @return 是否是假期和假期名称
#'
is_holiday_period <- function(date) {
  
  uk_holidays <- holidays::uk(year = year(date))
  
  if (date %in% uk_holidays) {
    return(list(is_holiday = TRUE, holiday_name = uk_holidays[date]))
  }
  
  # 检查是否在银行假日周末附近
  for (delta in -2:2) {
    check_date <- date + delta
    if (check_date %in% uk_holidays) {
      return(list(is_holiday = TRUE, holiday_name = "Bank Holiday Period"))
    }
  }
  
  return(list(is_holiday = FALSE, holiday_name = NA_character_))
}

#' 应用假期调整
#'
#' @param base_price 基础价格
#' @param date 日期
#' @return 调整后的价格、乘数和原因
#'
apply_holiday_adjustment <- function(base_price, date = Sys.Date()) {
  
  holiday_info <- is_holiday_period(date)
  
  if (holiday_info$is_holiday) {
    holiday_name <- holiday_info$holiday_name
    
    if (grepl("Christmas|New Year", holiday_name, ignore.case = TRUE)) {
      adjustment <- 1.35
      reason <- glue::glue("圣诞/新年高峰 - {holiday_name}")
    } else if (grepl("Easter|Spring", holiday_name, ignore.case = TRUE)) {
      adjustment <- 1.20
      reason <- glue::glue("春季假期 - {holiday_name}")
    } else {
      adjustment <- 1.15
      reason <- "银行假日周期"
    }
  } else {
    adjustment <- 1.0
    reason <- "普通日期"
  }
  
  adjusted_price <- base_price * adjustment
  
  return(list(
    adjusted_price = adjusted_price,
    adjustment = adjustment,
    reason = reason
  ))
}

#' 基于需求的价格调整
#'
#' @param df 数据框
#' @param neighbourhood 地段
#' @param room_type 房型
#' @param occupancy_rate 预测的占用率
#' @return 调整后的价格和乘数
#'
get_demand_based_price <- function(df, neighbourhood, room_type, occupancy_rate) {
  
  similar <- df %>%
    filter(
      neighbourhood == !!neighbourhood,
      room_type == !!room_type
    )
  
  if (nrow(similar) == 0) {
    return(NULL)
  }
  
  avg_market_occupancy <- mean(similar$occupancy_rate, na.rm = TRUE)
  base_price <- median(similar$price, na.rm = TRUE)
  
  # 需求调整逻辑
  if (occupancy_rate > avg_market_occupancy + 0.2) {
    multiplier <- 1.25
    reason <- "高需求 - 建议提价25%"
  } else if (occupancy_rate > avg_market_occupancy + 0.1) {
    multiplier <- 1.10
    reason <- "中高需求 - 建议提价10%"
  } else if (occupancy_rate < avg_market_occupancy - 0.2) {
    multiplier <- 0.80
    reason <- "低需求 - 建议降价20%"
  } else if (occupancy_rate < avg_market_occupancy - 0.1) {
    multiplier <- 0.90
    reason <- "中低需求 - 建议降价10%"
  } else {
    multiplier <- 1.0
    reason <- "需求符合市场平均水平"
  }
  
  adjusted_price <- base_price * multiplier
  
  return(list(
    base_price = as.numeric(base_price),
    adjusted_price = as.numeric(adjusted_price),
    multiplier = multiplier,
    reason = reason,
    market_occupancy_rate = avg_market_occupancy,
    your_occupancy_rate = occupancy_rate
  ))
}

#' 生成综合定价建议
#'
#' @param df 数据框
#' @param neighbourhood 地段
#' @param room_type 房型
#' @param current_price 当前价格
#' @param predicted_occupancy_rate 预测的占用率
#' @param minimum_nights 最小夜数
#' @return 完整的定价建议
#'
generate_pricing_recommendation <- function(df, neighbourhood, room_type,
                                           current_price, predicted_occupancy_rate,
                                           minimum_nights = 1) {
  
  # 1. 获取基础价格
  base_pricing <- get_base_price(df, neighbourhood, room_type)
  if (is.null(base_pricing)) {
    return(NULL)
  }
  
  # 2. 需求调整
  demand_adjustment <- get_demand_based_price(
    df, neighbourhood, room_type, predicted_occupancy_rate
  )
  
  # 3. 季节性调整示例（当前月份）
  today <- Sys.Date()
  seasonal_mult <- calculate_seasonal_multiplier(today)
  seasonal_adjusted <- base_pricing$base_price * seasonal_mult
  
  # 4. 综合建议
  recommended_price <- demand_adjustment$adjusted_price
  
  # 5. 价格范围
  min_price <- max(
    base_pricing$price_25_percentile * 0.9,
    current_price * 0.8
  )
  max_price <- base_pricing$price_75_percentile * 1.1
  
  recommendation <- list(
    current_price = as.numeric(current_price),
    base_market_price = as.numeric(base_pricing$base_price),
    market_price_range = list(
      min = as.numeric(base_pricing$price_25_percentile),
      max = as.numeric(base_pricing$price_75_percentile),
      median = as.numeric(base_pricing$base_price)
    ),
    recommended_price = round(as.numeric(recommended_price), 2),
    recommended_price_range = list(
      conservative = round(as.numeric(min_price), 2),
      optimized = round(as.numeric(recommended_price), 2),
      aggressive = round(as.numeric(max_price), 2)
    ),
    seasonal_adjustment = list(
      current_month_multiplier = seasonal_mult,
      seasonal_adjusted_price = round(as.numeric(seasonal_adjusted), 2)
    ),
    demand_adjustment = list(
      multiplier = demand_adjustment$multiplier,
      reason = demand_adjustment$reason,
      market_occupancy = round(demand_adjustment$market_occupancy_rate, 3),
      predicted_occupancy = predicted_occupancy_rate
    ),
    price_change_from_current = list(
      amount = round(recommended_price - current_price, 2),
      percentage = round((recommended_price - current_price) / current_price * 100, 1)
    ),
    comparable_listings = base_pricing$comparable_listings,
    market_insights = list(
      average_market_price = as.numeric(base_pricing$average_price),
      average_occupancy_rate = base_pricing$avg_occupancy_rate,
      price_volatility = as.numeric(base_pricing$price_std)
    )
  )
  
  return(recommendation)
}

#' 获取定价建议
#'
#' @param df 数据框
#' @param room_type 房型
#' @param neighbourhood 地段
#' @return 定价建议列表
#'
get_pricing_tips <- function(df, room_type, neighbourhood) {
  
  similar <- df %>%
    filter(
      neighbourhood == !!neighbourhood,
      room_type == !!room_type
    )
  
  tips <- list()
  
  if (nrow(similar) > 0) {
    avg_occupancy <- mean(similar$occupancy_rate, na.rm = TRUE)
    avg_reviews <- mean(similar$reviews_per_month, na.rm = TRUE)
    
    if (avg_occupancy > 0.8) {
      tips[[length(tips) + 1]] <- "💡 该地段该房型需求很高 (占用率>80%)，可考虑提价"
    } else if (avg_occupancy < 0.5) {
      tips[[length(tips) + 1]] <- "⚠️ 该地段该房型需求较低 (占用率<50%)，考虑降价以增加预订"
    }
    
    if (avg_reviews > 1.0) {
      tips[[length(tips) + 1]] <- "⭐ 高评论率表示房客满意度高，可维持或适度提价"
    }
    
    price_range <- quantile(similar$price, c(0.25, 0.75), na.rm = TRUE)
    tips[[length(tips) + 1]] <- glue::glue(
      "📊 类似房型价格范围: £{round(price_range[1])} - £{round(price_range[2])}"
    )
  } else {
    tips[[length(tips) + 1]] <- "⚠️ 该组合的数据不足，建议参考相邻地段或房型"
  }
  
  tips[[length(tips) + 1]] <- "💰 高峰季(5-9月)可提价20-30%"
  tips[[length(tips) + 1]] <- "🎄 节假日期间可提价15-35%"
  tips[[length(tips) + 1]] <- "📅 淡季(1月, 11-12月)可考虑降价10-15%"
  
  return(tips)
}

