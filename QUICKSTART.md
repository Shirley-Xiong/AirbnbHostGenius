# 🚀 快速启动指南

## 环境要求

- **R 版本**: 4.0+
- **RStudio** (推荐)
- 互联网连接（用于安装包）

## 📥 第1步: 安装依赖包

在 RStudio 的 R Console 中运行以下命令：

```r
# 安装所有必需的包
install.packages(c(
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
), dependencies = TRUE)
```

**预计安装时间**: 5-15分钟（取决于网络速度）

## 📂 第2步: 检查文件结构

确保项目文件结构如下：

```
/Users/xiongyi/Desktop/Airbnb/
├── AirbnbHostGenius/
│   ├── R/
│   │   ├── 00_load_data.R              ✓
│   │   ├── 01_descriptive_analysis.R   ✓
│   │   ├── 02_predictive_models.R      ✓
│   │   └── 03_pricing_engine.R         ✓
│   ├── app.R                           ✓
│   ├── README.md                       ✓
│   ├── QUICKSTART.md                   ✓
│   └── requirements.R                  ✓
└── listings (3).csv                    ✓ (数据文件)
```

## 🎯 第3步: 运行应用

### 选项A: 使用RStudio (推荐)

1. 在RStudio中打开 `app.R`
2. 点击右上角的 **Run App** 按钮
3. 或在Console运行：
```r
setwd("/Users/xiongyi/Desktop/Airbnb/AirbnbHostGenius")
shiny::runApp("app.R")
```

### 选项B: 使用R命令行

```r
setwd("/Users/xiongyi/Desktop/Airbnb/AirbnbHostGenius")
shiny::runApp("app.R", launch.browser = TRUE)
```

## ✅ 验证安装

应用应该会在浏览器中打开，通常地址是 `http://localhost:3838`

你应该看到：
- 左侧导航菜单（市场分析、房产工具、定价工具）
- 顶部显示4个统计卡片
- 各种图表和表格

## 📊 功能说明

### 1️⃣ 市场分析标签
- 查看伦敦市场总体概览
- 房型分布和收入对比
- 各地段排名和详细数据

### 2️⃣ 房产工具标签
- 输入房产信息（地段、房型、价格等）
- 点击"进行预测"获取预测结果
- 查看年租赁天数和年收入预测

### 3️⃣ 定价工具标签
- 输入房产基本信息和预测入住率
- 点击"获取定价建议"
- 查看推荐价格和定价技巧

## 🔧 常见问题

### Q: 如何修改数据源路径?

在 `app.R` 中找到第22行，修改：
```r
csv_path <- "your/new/path/listings.csv"
```

### Q: 应用启动很慢

首次加载会比较慢，因为需要：
1. 读取和清洗95,000+条数据
2. 训练机器学习模型

后续访问会快很多（模型已缓存）

### Q: 如何更新预测模型?

编辑 `R/02_predictive_models.R` 中的参数：
- `max_depth`: 树的最大深度
- `eta`: 学习率
- `nrounds`: 迭代次数

### Q: 如何自定义UI样式?

编辑 `app.R` 中的 `dashboardBody()` 部分，或修改CSS：
```r
tags$style(HTML("
  /* 自定义CSS */
"))
```

## 📈 性能优化

**数据加载优化** (如果数据过大)：
```r
# 在 00_load_data.R 中
df <- read_csv(csv_path, n_max = 50000)  # 限制行数
```

**模型优化**:
```r
# 在 02_predictive_models.R 中
nrounds = 50  # 减少迭代次数（更快但精度可能降低）
```

## 🆘 故障排查

### 错误: "找不到文件"
```
✗ 检查数据文件路径是否正确
✗ 检查工作目录是否正确 (getwd())
✗ 确保文件名拼写正确
```

### 错误: "包未安装"
```r
# 运行以下命令安装缺失的包
install.packages("package_name")
```

### 错误: "模型训练失败"
```
✗ 检查数据是否加载成功
✗ 检查特征列是否存在
✗ 检查xgboost包版本是否兼容
```

## 📚 进一步阅读

- [Shiny官方文档](https://shiny.rstudio.com/)
- [shinydashboard指南](https://rstudio.github.io/shinydashboard/)
- [tidyverse数据处理](https://r4ds.hadley.nz/)
- [caret机器学习](https://topepo.github.io/caret/)

## 🎓 示例使用流程

1. **打开应用** → 看到市场分析仪表板
2. **切换到房产工具** → 输入房产信息
   - 地段: Islington
   - 房型: Private room
   - 价格: £80
3. **点击预测** → 查看年租赁天数和收入
4. **切换到定价工具** → 获取定价建议
   - 当前价格: £80
   - 入住率: 60%
5. **查看结果** → 获得推荐价格和技巧

## 💡 下一步

- **自定义分析**: 修改分析维度和指标
- **集成更多数据**: 添加其他城市数据
- **部署到服务器**: 使用Shiny Server部署
- **添加数据库**: 集成MySQL/PostgreSQL存储结果

## 📞 支持

遇到问题? 检查:
1. R版本 (`R.version`)
2. 包版本 (`packageVersion("package_name")`)
3. 工作目录 (`getwd()`)
4. 数据文件位置

---

**祝你使用愉快! 🎉**

