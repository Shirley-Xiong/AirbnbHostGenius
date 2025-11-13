# 预测模型模块 - 预测年租赁天数和年收入
# ====================================

library(tidyverse)
library(caret)
library(xgboost)
library(data.table)

# 全局变量存储训练好的模型
occupancy_model <- NULL
revenue_model <- NULL
label_encoders <- list()
feature_columns <- NULL

#' 准备预测特征
#'
#' @param df 数据框
#' @param training 是否是训练模式
#' @return 特征矩阵
#'
prepare_features <- function(df, training = FALSE) {
  
  # 选择特征
  features_to_use <- c('price', 'minimum_nights', 'number_of_reviews', 
                       'reviews_per_month', 'room_type', 'neighbourhood')
  
  df_features <- df %>% select(all_of(features_to_use))
  
  # 编码分类变量
  categorical_cols <- c('room_type', 'neighbourhood')
  
  for (col in categorical_cols) {
    if (training) {
      # 训练模式：学习编码
      label_encoders[[col]] <<- as.character(unique(df[[col]]))
    }
    
    # 将类别转换为数字
    df_features[[col]] <- match(df_features[[col]], label_encoders[[col]]) - 1
  }
  
  feature_columns <<- features_to_use
  
  return(as.matrix(df_features))
}

#' 训练占用率预测模型
#'
#' @param df 数据框
#' @param test_size 测试集比例
#' @return 模型评估指标
#'
train_occupancy_model <- function(df, test_size = 0.2) {
  
  message("🔄 训练占用率模型...")
  
  # 初始化标签编码器（如果未初始化）
  if (length(label_encoders) == 0) {
    label_encoders$room_type <<- as.character(unique(df$room_type))
    label_encoders$neighbourhood <<- as.character(unique(df$neighbourhood))
  }
  
  # 准备数据
  X <- prepare_features(df, training = TRUE)
  y <- df$annual_occupied_days
  
  # 分割数据
  set.seed(42)
  train_idx <- createDataPartition(y, p = 1 - test_size, list = FALSE)
  
  X_train <- X[train_idx, ]
  X_test <- X[-train_idx, ]
  y_train <- y[train_idx]
  y_test <- y[-train_idx]
  
  # 训练XGBoost模型
  occupancy_model <<- xgboost(
    data = X_train,
    label = y_train,
    nrounds = 100,
    max_depth = 5,
    eta = 0.1,
    objective = "reg:squarederror",
    eval_metric = "rmse",
    verbose = 0
  )
  
  # 评估
  y_pred_train <- predict(occupancy_model, X_train)
  y_pred_test <- predict(occupancy_model, X_test)
  
  # 计算R²
  r2_train <- 1 - (sum((y_train - y_pred_train)^2) / sum((y_train - mean(y_train))^2))
  r2_test <- 1 - (sum((y_test - y_pred_test)^2) / sum((y_test - mean(y_test))^2))
  mae_test <- mean(abs(y_test - y_pred_test))
  
  message(glue::glue("  ✓ 训练R²: {round(r2_train, 3)}"))
  message(glue::glue("  ✓ 测试R²: {round(r2_test, 3)}"))
  message(glue::glue("  ✓ 测试MAE: {round(mae_test, 2)} 天"))
  
  return(list(
    train_r2 = r2_train,
    test_r2 = r2_test,
    test_mae = mae_test
  ))
}

#' 训练收入预测模型
#'
#' @param df 数据框
#' @param test_size 测试集比例
#' @return 模型评估指标
#'
train_revenue_model <- function(df, test_size = 0.2) {
  
  message("🔄 训练收入模型...")
  
  # 确保标签编码器已初始化
  if (length(label_encoders) == 0) {
    label_encoders$room_type <<- as.character(unique(df$room_type))
    label_encoders$neighbourhood <<- as.character(unique(df$neighbourhood))
  }
  
  # 准备数据
  X <- prepare_features(df, training = TRUE)
  y <- df$estimated_annual_revenue
  
  # 分割数据
  set.seed(42)
  train_idx <- createDataPartition(y, p = 1 - test_size, list = FALSE)
  
  X_train <- X[train_idx, ]
  X_test <- X[-train_idx, ]
  y_train <- y[train_idx]
  y_test <- y[-train_idx]
  
  # 训练XGBoost模型
  revenue_model <<- xgboost(
    data = X_train,
    label = y_train,
    nrounds = 100,
    max_depth = 5,
    eta = 0.1,
    objective = "reg:squarederror",
    eval_metric = "rmse",
    verbose = 0
  )
  
  # 评估
  y_pred_train <- predict(revenue_model, X_train)
  y_pred_test <- predict(revenue_model, X_test)
  
  # 计算R²
  r2_train <- 1 - (sum((y_train - y_pred_train)^2) / sum((y_train - mean(y_train))^2))
  r2_test <- 1 - (sum((y_test - y_pred_test)^2) / sum((y_test - mean(y_test))^2))
  mae_test <- mean(abs(y_test - y_pred_test))
  
  message(glue::glue("  ✓ 训练R²: {round(r2_train, 3)}"))
  message(glue::glue("  ✓ 测试R²: {round(r2_test, 3)}"))
  message(glue::glue("  ✓ 测试MAE: £{round(mae_test, 2)}"))
  
  return(list(
    train_r2 = r2_train,
    test_r2 = r2_test,
    test_mae = mae_test
  ))
}

#' 预测占用天数
#'
#' @param price 价格
#' @param minimum_nights 最小夜数
#' @param number_of_reviews 评论数
#' @param reviews_per_month 每月评论数
#' @param room_type 房型
#' @param neighbourhood 地段
#' @return 预测结果
#'
predict_occupancy <- function(price, minimum_nights, number_of_reviews,
                             reviews_per_month, room_type, neighbourhood) {
  
  if (is.null(occupancy_model)) {
    stop("模型未训练")
  }
  
  # 创建特征数据框
  X_new <- data.frame(
    price = price,
    minimum_nights = minimum_nights,
    number_of_reviews = number_of_reviews,
    reviews_per_month = reviews_per_month,
    room_type = room_type,
    neighbourhood = neighbourhood
  )
  
  # 编码
  X_new$room_type <- match(X_new$room_type, label_encoders$room_type) - 1
  X_new$neighbourhood <- match(X_new$neighbourhood, label_encoders$neighbourhood) - 1
  
  # 预测
  pred <- predict(occupancy_model, as.matrix(X_new))
  pred <- max(0, min(365, pred))  # 限制在0-365之间
  
  return(list(
    predicted_occupied_days = as.integer(round(pred)),
    confidence = 0.85,
    lower_bound = as.integer(round(pred * 0.8)),
    upper_bound = as.integer(round(pred * 1.2))
  ))
}

#' 预测年收入
#'
#' @param price 价格
#' @param minimum_nights 最小夜数
#' @param number_of_reviews 评论数
#' @param reviews_per_month 每月评论数
#' @param room_type 房型
#' @param neighbourhood 地段
#' @return 预测结果
#'
predict_revenue <- function(price, minimum_nights, number_of_reviews,
                           reviews_per_month, room_type, neighbourhood) {
  
  if (is.null(revenue_model)) {
    stop("模型未训练")
  }
  
  # 创建特征数据框
  X_new <- data.frame(
    price = price,
    minimum_nights = minimum_nights,
    number_of_reviews = number_of_reviews,
    reviews_per_month = reviews_per_month,
    room_type = room_type,
    neighbourhood = neighbourhood
  )
  
  # 编码
  X_new$room_type <- match(X_new$room_type, label_encoders$room_type) - 1
  X_new$neighbourhood <- match(X_new$neighbourhood, label_encoders$neighbourhood) - 1
  
  # 预测
  pred <- predict(revenue_model, as.matrix(X_new))
  pred <- max(0, pred)  # 不能为负
  
  return(list(
    predicted_annual_revenue = round(pred, 2),
    confidence = 0.85,
    lower_bound = round(pred * 0.8, 2),
    upper_bound = round(pred * 1.2, 2)
  ))
}

#' 使用输入数据进行预测
#'
#' @param property_info 房产信息列表
#' @return 完整预测结果
#'
predict_with_inputs <- function(property_info) {
  
  occupancy_pred <- predict_occupancy(
    property_info$price,
    property_info$minimum_nights,
    property_info$number_of_reviews,
    property_info$reviews_per_month,
    property_info$room_type,
    property_info$neighbourhood
  )
  
  revenue_pred <- predict_revenue(
    property_info$price,
    property_info$minimum_nights,
    property_info$number_of_reviews,
    property_info$reviews_per_month,
    property_info$room_type,
    property_info$neighbourhood
  )
  
  return(list(
    occupancy = occupancy_pred,
    revenue = revenue_pred
  ))
}

#' 获取特征重要性
#'
#' @return 特征重要性数据框
#'
get_feature_importance <- function() {
  
  if (is.null(occupancy_model)) {
    return(NULL)
  }
  
  importance_df <- xgb.importance(feature_names = feature_columns, 
                                   model = occupancy_model)
  
  return(importance_df %>% 
           as.data.frame() %>%
           mutate(Importance_pct = Gain * 100) %>%
           select(Feature, Gain, Importance_pct))
}

