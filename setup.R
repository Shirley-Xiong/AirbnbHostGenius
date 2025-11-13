# 一键安装和配置脚本
# ====================================

cat("\n")
cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║   Airbnb房东数据分析平台 - 安装和配置脚本                       ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# 检查R版本
r_version <- paste(R.version$major, R.version$minor, sep = ".")
cat(glue::glue("✓ 当前R版本: {r_version}\n"))

if (as.numeric(R.version$major) < 4) {
  cat("⚠️  警告: 推荐使用R 4.0+\n")
}

cat("\n")

# 要安装的包列表
required_packages <- c(
  "shiny",
  "shinydashboard",
  "shinyWidgets",
  "shinyjs",
  "tidyverse",
  "data.table",
  "readr",
  "caret",
  "xgboost",
  "randomForest",
  "gbm",
  "ggplot2",
  "plotly",
  "scales",
  "lubridate",
  "holidays",
  "stringr",
  "glue",
  "modelr",
  "broom"
)

# 检查已安装的包
installed_packages <- installed.packages()[, "Package"]
missing_packages <- setdiff(required_packages, installed_packages)

if (length(missing_packages) == 0) {
  cat("✓ 所有依赖包已安装\n")
} else {
  cat(glue::glue("📦 需要安装 {length(missing_packages)} 个包:\n"))
  cat(paste("  -", missing_packages, collapse = "\n"), "\n")
  cat("\n")
  
  response <- readline("是否现在安装? (y/n): ")
  
  if (tolower(response) == "y") {
    cat("\n🔄 安装中... (这可能需要几分钟)\n")
    
    install.packages(missing_packages, dependencies = TRUE, quiet = TRUE)
    
    cat("✓ 安装完成!\n")
  } else {
    cat("⚠️  跳过安装。请稍后手动安装依赖包。\n")
  }
}

cat("\n")

# 检查数据文件
csv_path <- "/Users/xiongyi/Desktop/Airbnb/listings (3).csv"

if (file.exists(csv_path)) {
  cat(glue::glue("✓ 数据文件已找到: {csv_path}\n"))
  
  # 获取文件大小
  file_size_mb <- round(file.size(csv_path) / (1024 * 1024), 2)
  cat(glue::glue("  文件大小: {file_size_mb} MB\n"))
} else {
  cat("⚠️  数据文件未找到!\n")
  cat(glue::glue("   预期路径: {csv_path}\n"))
  cat("   请确保数据文件在正确的位置\n")
}

cat("\n")

# 显示启动选项
cat("════════════════════════════════════════════════════════════════\n")
cat("🚀 准备就绪! 选择启动方式:\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("\n")
cat("选项 1: 启动Shiny应用\n")
cat("  运行: shiny::runApp('app.R')\n")
cat("\n")
cat("选项 2: 在RStudio中打开app.R并点击 'Run App' 按钮\n")
cat("\n")
cat("选项 3: 使用launch.browser参数自动打开浏览器\n")
cat("  运行: shiny::runApp('app.R', launch.browser = TRUE)\n")
cat("\n")

# 提供启动函数
cat("💡 快速启动函数:\n")

cat("
launch_app <- function() {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  shiny::runApp('app.R', launch.browser = TRUE)
}

# 直接运行
launch_app()
")

cat("\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("✓ 安装和配置完成!\n")
cat("📖 查看 README.md 了解更多信息\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("\n")

