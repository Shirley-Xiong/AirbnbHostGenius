# 🏠 Airbnb房东数据分析平台 (R版本)

一个为Airbnb房东提供的智能数据分析和定价建议平台，采用**R + Shiny**构建，集成了描述性分析和预测性分析功能。

## ✨ 核心功能

✅ **描述性分析** - 房产市场数据洞察和可视化  
✅ **预测模型** - 预测年租赁天数和年收入  
✅ **智能定价** - 基于地段、房型、季节性的动态定价建议  
✅ **交互式仪表板** - 实时数据可视化和分析  

## 🗂️ 项目结构

```
AirbnbHostGenius/
├── data/
│   ├── raw/                    # 原始CSV数据
│   └── processed/              # 处理后的数据
├── R/
│   ├── 00_load_data.R         # 数据加载和清洗
│   ├── 01_descriptive_analysis.R  # 描述性分析
│   ├── 02_predictive_models.R     # 预测模型
│   ├── 03_pricing_engine.R        # 定价引擎
│   └── utils.R                    # 工具函数
├── app.R                       # Shiny主应用
├── requirements.R              # R包依赖
└── README.md                   # 项目说明
```

## 🚀 快速开始

### 1. 安装依赖包

```r
# 在R console中运行以下命令安装所有依赖
install.packages(c(
  "shiny", "shinydashboard", "shinyWidgets", "shinyjs",
  "tidyverse", "data.table", "readr",
  "caret", "xgboost", "randomForest", "gbm",
  "ggplot2", "plotly", "scales",
  "lubridate", "holidays", "stringr", "glue",
  "modelr", "broom"
))
```

### 2. 运行应用

```r
# 在R console中运行
setwd("your/path/to/AirbnbHostGenius")
shiny::runApp("app.R")
```

应用将在 `http://localhost:3838` 打开

### 3. 准备数据

确保 `listings (3).csv` 文件位于项目根目录的上一级：
```
/Users/xiongyi/Desktop/Airbnb/listings (3).csv
```

## 📊 数据来源

- **listings (3).csv** - 伦敦Airbnb房产数据
  - 95,000+ 条房产记录
  - 包含价格、评分、地段、房型等信息

## 🎯 主要分析指标

### Descriptive Analysis（描述性分析）
- 房产总数、平均价格、房型分布
- 各地段的入住率、评分、收入
- 价格与入住率的相关性分析
- 房型对比和市场排名

### Predictive Analysis（预测性分析）
- 基于房型、地段、最小夜数等预测**年租赁天数**
- 预测**年收入** = 价格 × 预测租赁天数
- 提供置信区间和预测范围
- 特征重要性分析

### 定价策略（Pricing Strategy）
- **基础定价**: 相同地段+房型的中位数
- **季节调整**: 
  - 高峰期(5-9月): 提价 20-30%
  - 平季(2-4, 10月): 保持
  - 淡季(1月, 11-12月): 降价 10-15%
  - 圣诞/新年: 提价 25-35%
- **假期调整**: 银行假日周期提价 15%
- **需求调整**: 根据预测占用率动态调整

## 💡 使用示例

### 1. 市场分析标签
- 查看市场概览（总房产、平均价格、入住率）
- 房型分布和收入对比
- 各地段排名和表现

### 2. 房产工具标签
- 输入房产信息（地段、房型、价格等）
- 获取预测：年租赁天数、年收入、置信区间
- 查看相似房产的市场数据

### 3. 定价工具标签
- 输入房产基本信息和预测入住率
- 获取智能定价建议
- 查看价格调整原因和范围
- 获取定价技巧和市场洞察

## 📈 技术架构

### 数据处理
- **tidyverse**: dplyr处理数据、ggplot2绘图
- **data.table**: 快速聚合和分组统计

### 预测模型
- **XGBoost**: 梯度提升树 (主要预测模型)
- **Random Forest**: 随机森林 (备选模型)
- **caret**: 统一的ML框架

### Web应用
- **Shiny**: 交互式Web框架
- **shinydashboard**: 现代化仪表板UI
- **plotly**: 交互式图表

### 工具
- **lubridate**: 日期时间处理
- **holidays**: UK节假日API
- **stringr/glue**: 字符串处理

## 🔧 配置说明

### 环境变量 (.Renviron)
```
DATA_PATH="/Users/xiongyi/Desktop/Airbnb/listings (3).csv"
MODEL_PATH="./models/"
```

### 模型参数调优
在 `02_predictive_models.R` 中可调整：
- XGBoost参数 (learning_rate, max_depth, n_rounds等)
- 训练集/测试集比例
- 交叉验证折数

## 📊 输出和导出

应用支持：
- 📥 下载分析报告 (HTML, PDF)
- 📊 导出图表 (PNG, SVG)
- 📋 导出数据表 (CSV, Excel)

## 🎓 学习资源

- [Shiny官方文档](https://shiny.rstudio.com/)
- [shinydashboard使用指南](https://rstudio.github.io/shinydashboard/)
- [caret机器学习](https://topepo.github.io/caret/)
- [ggplot2数据可视化](https://ggplot2.tidyverse.org/)

## ⚡ 性能优化

- 数据缓存机制：避免重复计算
- 模型预加载：启动时加载训练好的模型
- 响应式编程：智能更新UI
- 异步处理：长时间计算使用后台任务

## 🤝 贡献和反馈

欢迎提出建议和改进意见！

## 📝 许可证

MIT License

---

**最后更新**: 2024年11月
**R版本**: 4.0+
**Shiny版本**: 1.7+

