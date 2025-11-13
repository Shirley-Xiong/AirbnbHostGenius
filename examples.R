# 示例分析脚本
# ====================================

library(tidyverse)
library(glue)

# 加载分析模块
source("R/00_load_data.R")
source("R/01_descriptive_analysis.R")
source("R/02_predictive_models.R")
source("R/03_pricing_engine.R")

# ===== 1. 加载和清洗数据 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("1️⃣  数据加载示例\n")
cat("═══════════════════════════════════════════════════════════════\n")

csv_path <- "/Users/xiongyi/Desktop/Airbnb/listings (3).csv"
airbnb_data <- load_and_clean_data(csv_path)

# 显示摘要统计
stats <- get_summary_stats(airbnb_data)
cat("\n📊 数据摘要:\n")
cat(glue("  总房产数: {stats$total_listings}\n"))
cat(glue("  平均价格: £{round(stats$avg_price, 2)}/晚\n"))
cat(glue("  中位数价格: £{round(stats$median_price, 2)}\n"))
cat(glue("  平均入住率: {round(stats$avg_occupancy_rate * 100, 1)}%\n"))
cat(glue("  平均年收入: £{round(stats$avg_estimated_annual_revenue, 0)}\n"))
cat(glue("  地段数: {stats$neighbourhoods}\n"))

# ===== 2. 市场分析 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("2️⃣  市场分析示例\n")
cat("═══════════════════════════════════════════════════════════════\n")

# 房型分析
room_type_analysis <- analyze_by_room_type(airbnb_data)
cat("\n📊 按房型分析:\n")
for (room_type in names(room_type_analysis)) {
  info <- room_type_analysis[[room_type]]
  cat(glue("\n  {room_type}:\n"))
  cat(glue("    房产数: {info$count}\n"))
  cat(glue("    平均价格: £{round(info$avg_price, 2)}\n"))
  cat(glue("    中位数价格: £{round(info$median_price, 2)}\n"))
  cat(glue("    平均入住率: {round(info$avg_occupancy_rate * 100, 1)}%\n"))
  cat(glue("    年均收入: £{round(info$avg_estimated_annual_revenue, 0)}\n"))
}

# 地段分析
neighbourhood_analysis <- analyze_by_neighbourhood(airbnb_data)
cat("\n📊 按地段分析 (前5个):\n")
for (i in 1:min(5, length(neighbourhood_analysis))) {
  neighbourhood <- names(neighbourhood_analysis)[i]
  info <- neighbourhood_analysis[[i]]
  cat(glue("\n  {neighbourhood}:\n"))
  cat(glue("    房产数: {info$listing_count}\n"))
  cat(glue("    平均价格: £{round(info$avg_price, 2)}\n"))
  cat(glue("    中位数价格: £{round(info$median_price, 2)}\n"))
  cat(glue("    平均入住率: {round(info$occupancy_rate * 100, 1)}%\n"))
  cat(glue("    年均收入: £{round(info$avg_annual_revenue, 0)}\n"))
}

# ===== 3. 相似房产查询 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("3️⃣  相似房产分析示例\n")
cat("═══════════════════════════════════════════════════════════════\n")

similar <- find_similar_properties(airbnb_data, "Islington", "Private room")

if (!is.null(similar)) {
  cat("\n📍 Islington - Private room 相似房产:\n")
  cat(glue("  房产数: {similar$count}\n"))
  cat(glue("  平均价格: £{round(similar$avg_price, 2)}\n"))
  cat(glue("  中位数价格: £{round(similar$median_price, 2)}\n"))
  cat(glue("  价格范围: £{round(similar$min_price, 2)} - £{round(similar$max_price, 2)}\n"))
  cat(glue("  平均入住率: {round(similar$avg_occupancy_rate * 100, 1)}%\n"))
  cat(glue("  年均收入: £{round(similar$avg_annual_revenue, 0)}\n"))
}

# ===== 4. 预测模型训练 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("4️⃣  预测模型训练示例\n")
cat("═══════════════════════════════════════════════════════════════\n")

cat("\n🔄 训练占用率预测模型...\n")
occupancy_metrics <- train_occupancy_model(airbnb_data)

cat("\n🔄 训练收入预测模型...\n")
revenue_metrics <- train_revenue_model(airbnb_data)

# ===== 5. 预测 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("5️⃣  预测示例\n")
cat("═══════════════════════════════════════════════════════════════\n")

# 示例房产
property_example <- list(
  price = 80,
  minimum_nights = 2,
  number_of_reviews = 50,
  reviews_per_month = 0.5,
  room_type = "Private room",
  neighbourhood = "Islington"
)

predictions <- predict_with_inputs(property_example)

cat("\n🏠 房产信息:\n")
cat(glue("  地段: {property_example$neighbourhood}\n"))
cat(glue("  房型: {property_example$room_type}\n"))
cat(glue("  价格: £{property_example$price}/晚\n"))
cat(glue("  最小夜数: {property_example$minimum_nights}\n"))
cat(glue("  评论数: {property_example$number_of_reviews}\n"))
cat(glue("  每月评论数: {property_example$reviews_per_month}\n"))

cat("\n🔮 预测结果:\n")
cat(glue("  年占用天数: {predictions$occupancy$predicted_occupied_days} 天\n"))
cat(glue("  占用天数范围: {predictions$occupancy$lower_bound} - {predictions$occupancy$upper_bound} 天\n"))
cat(glue("  年收入预测: £{predictions$revenue$predicted_annual_revenue}\n"))
cat(glue("  收入范围: £{predictions$revenue$lower_bound} - £{predictions$revenue$upper_bound}\n"))

# ===== 6. 定价建议 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("6️⃣  定价建议示例\n")
cat("═══════════════════════════════════════════════════════════════\n")

recommendation <- generate_pricing_recommendation(
  airbnb_data,
  neighbourhood = "Islington",
  room_type = "Private room",
  current_price = 80,
  predicted_occupancy_rate = 0.75
)

if (!is.null(recommendation)) {
  cat("\n💰 定价建议:\n")
  cat(glue("  当前价格: £{recommendation$current_price}\n"))
  cat(glue("  市场中位数: £{round(recommendation$base_market_price, 2)}\n"))
  cat(glue("  市场平均价格: £{round(recommendation$market_insights$average_market_price, 2)}\n"))
  cat(glue("  市场价格范围: £{recommendation$market_price_range$min} - £{recommendation$market_price_range$max}\n"))
  
  cat("\n🎯 推荐价格:\n")
  cat(glue("  基础推荐: £{recommendation$recommended_price}\n"))
  cat(glue("  保守策略: £{recommendation$recommended_price_range$conservative}\n"))
  cat(glue("  激进策略: £{recommendation$recommended_price_range$aggressive}\n"))
  
  price_change <- recommendation$price_change_from_current
  sign <- if (price_change$amount >= 0) "+" else ""
  cat("\n📈 价格调整:\n")
  cat(glue("  变化: {sign}£{round(price_change$amount, 2)} ({sign}{price_change$percentage}%)\n"))
  
  cat("\n📊 需求分析:\n")
  cat(glue("  {recommendation$demand_adjustment$reason}\n"))
  cat(glue("  市场入住率: {round(recommendation$demand_adjustment$market_occupancy * 100, 1)}%\n"))
  cat(glue("  预测入住率: {round(recommendation$demand_adjustment$predicted_occupancy * 100, 1)}%\n"))
  
  cat("\n🌡️  季节性调整:\n")
  cat(glue("  当月乘数: {recommendation$seasonal_adjustment$current_month_multiplier}\n"))
  cat(glue("  季节性建议价格: £{recommendation$seasonal_adjustment$seasonal_adjusted_price}\n"))
}

# 定价技巧
tips <- get_pricing_tips(airbnb_data, "Private room", "Islington")
cat("\n💡 定价技巧:\n")
for (tip in tips) {
  cat(glue("  • {tip}\n"))
}

# ===== 7. 完整市场报告 =====
cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("7️⃣  完整市场报告\n")
cat("═══════════════════════════════════════════════════════════════\n")

market_report <- generate_market_report(airbnb_data)

cat("\n📋 市场概览:\n")
overview <- market_report$market_overview
cat(glue("  总房产数: {overview$total_listings}\n"))
cat(glue("  平均价格: £{round(overview$average_price, 2)}\n"))
cat(glue("  中位数价格: £{round(overview$median_price, 2)}\n"))
cat(glue("  价格范围: £{round(overview$price_range$min, 2)} - £{round(overview$price_range$max, 2)}\n"))
cat(glue("  平均入住率: {round(overview$average_occupancy_rate * 100, 1)}%\n"))

cat("\n✓ 分析完成!\n")

cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("💡 下一步:\n")
cat("  1. 运行 'shiny::runApp(\"app.R\")' 启动Web应用\n")
cat("  2. 或在 RStudio 中打开 app.R 并点击 'Run App'\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("\n")

