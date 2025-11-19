# 🔧 完整安装指南

## 环境要求

### 必需
- **操作系统**: macOS, Windows, Linux
- **R版本**: 4.0+ (推荐 4.3+)
- **内存**: 至少 4GB (8GB推荐)
- **磁盘空间**: 至少 500MB

### 推荐
- **RStudio**: 最新版本 (https://posit.co/download/rstudio-desktop/)
- **网络连接**: 用于包安装 (100+ MB)

---

## 步骤1️⃣: 安装R和RStudio

### macOS
```bash
# 使用Homebrew
brew install r

# 或从官网下载
# https://cran.r-project.org/bin/macosx/
```

### Windows
访问 https://cran.r-project.org/bin/windows/base/ 下载安装程序

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install r-base r-base-dev
```

---

## 步骤2️⃣: 安装RStudio

下载地址: https://posit.co/download/rstudio-desktop/

选择对应操作系统的版本并安装。

---

## 步骤3️⃣: 验证R安装

打开R或RStudio控制台，运行：

```r
# 查看R版本
R.version

# 应该显示类似：
# R version 4.3.0+ ...
```

---

## 步骤4️⃣: 一键安装所有依赖包

### 方法A: 使用setup.R脚本 (推荐)

1. 在RStudio中打开 `setup.R`
2. 运行整个脚本，或在Console中运行：

```r
setwd("/Users/xiongyi/Desktop/Airbnb/AirbnbHostGenius")
source("setup.R")
```

3. 按照提示完成安装

### 方法B: 手动安装

在R Console中复制粘贴以下代码：

```r
# 安装所有依赖包
packages_to_install <- c(
  "shiny",           # Web框架
  "shinydashboard",  # 仪表板
  "shinyWidgets",    # 增强组件
  "shinyjs",         # JavaScript交互
  "tidyverse",       # 数据处理和可视化
  "data.table",      # 快速数据处理
  "readr",           # CSV读取
  "caret",           # 机器学习框架
  "xgboost",         # 梯度提升
  "randomForest",    # 随机森林
  "gbm",             # 梯度提升
  "ggplot2",         # 可视化
  "plotly",          # 交互式图表
  "scales",          # 尺度缩放
  "lubridate",       # 日期处理
  "holidays",        # 节假日处理
  "stringr",         # 字符串处理
  "glue",            # 字符串插值
  "modelr",          # 建模工具
  "broom"            # 模型整理
)

# 一次性安装所有包
install.packages(packages_to_install, dependencies = TRUE)
```

**安装时间**: 5-15分钟(取决于网络)

---

## 步骤5️⃣: 验证安装

在R Console中运行以下代码验证所有包都已正确安装：

```r
# 检查所有必需的包
required_packages <- c(
  "shiny", "shinydashboard", "shinyWidgets", "shinyjs",
  "tidyverse", "data.table", "readr",
  "caret", "xgboost", "randomForest", "gbm",
  "ggplot2", "plotly", "scales",
  "lubridate", "holidays", "stringr", "glue",
  "modelr", "broom"
)

# 检查是否都已安装
missing <- setdiff(required_packages, rownames(installed.packages()))

if (length(missing) == 0) {
  cat("✓ 所有依赖包已成功安装!\n")
} else {
  cat("✗ 缺少以下包:\n")
  print(missing)
}
```

应该输出: `✓ 所有依赖包已成功安装!`

---

## 步骤6️⃣: 配置数据文件

确保数据文件位于正确位置：

```
/Users/xiongyi/Desktop/Airbnb/listings (3).csv
```

### 验证文件
在R中运行：

```r
# 检查文件是否存在
csv_path <- "/Users/xiongyi/Desktop/Airbnb/listings (3).csv"

if (file.exists(csv_path)) {
  cat("✓ 数据文件已找到\n")
  
  # 显示文件大小
  size_mb <- file.size(csv_path) / (1024 * 1024)
  cat(glue::glue("  文件大小: {round(size_mb, 2)} MB\n"))
  
} else {
  cat("✗ 数据文件未找到!\n")
  cat(glue::glue("  预期位置: {csv_path}\n"))
}
```

---

## 步骤7️⃣: 启动应用

### 方法A: RStudio (推荐) 🌟

1. 打开RStudio
2. 打开文件: `File` → `Open File` → 选择 `app.R`
3. 点击右上角的 **"Run App"** 按钮
4. 应用会在浏览器中自动打开 (http://localhost:3838)

### 方法B: R命令行

在R Console中运行：

```r
# 设置工作目录
setwd("/Users/xiongyi/Desktop/Airbnb/AirbnbHostGenius")

# 启动应用
shiny::runApp("app.R", launch.browser = TRUE)
```

### 方法C: 快捷启动函数

在R Console中创建启动函数：

```r
launch_airbnb_app <- function() {
  setwd("/Users/xiongyi/Desktop/Airbnb/AirbnbHostGenius")
  shiny::runApp("app.R", launch.browser = TRUE)
}

# 使用
launch_airbnb_app()
```

---

## 首次启动预期

### 启动序列
```
1. 加载R包 (2-3秒)
   ✓ shiny, shinydashboard等
   
2. 加载数据 (5-10秒)
   ✓ 读取 95,000+ 条记录
   ✓ 数据清洗
   
3. 训练模型 (30-60秒)
   ✓ 占用率预测模型
   ✓ 收入预测模型
   
4. 启动应用 (5-10秒)
   ✓ 初始化Shiny服务器
   
5. 打开浏览器 (<1秒)
   ✓ 应用已就绪!
```

**总耗时**: 1-2分钟 (首次)

### 控制台输出示例
```
✓ 成功加载数据: 95466 条记录
✓ 清洗后: 94123 条有效记录
🔄 训练占用率模型...
  ✓ 训练R²: 0.723
  ✓ 测试R²: 0.685
  ✓ 测试MAE: 24.3 天
🔄 训练收入模型...
  ✓ 训练R²: 0.698
  ✓ 测试R²: 0.642
  ✓ 测试MAE: £1245
✓ 模型加载完成
Listening on http://127.0.0.1:3838
```

---

## 🌐 应用已就绪

应用启动后，你应该看到：

1. **顶部导航栏** - "Airbnb房东助手" 标题
2. **左侧菜单** - 三个标签页选项
3. **主内容区** - 市场分析仪表板
4. **统计卡片** - 显示市场数据

---

## ⚡ 快速故障排查

### 问题: 包安装失败

```r
# 原因: 网络问题或R版本过低
# 解决:

# 1. 检查R版本
R.version

# 2. 使用备用镜像 (中国用户)
options(repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")

# 3. 重新安装单个包
install.packages("package_name", dependencies = TRUE)
```

### 问题: 应用无法启动

```r
# 原因: 工作目录错误或文件不存在
# 解决:

# 1. 检查工作目录
getwd()

# 2. 设置正确的工作目录
setwd("/Users/xiongyi/Desktop/Airbnb/AirbnbHostGenius")

# 3. 验证app.R存在
file.exists("app.R")

# 4. 再试一次
shiny::runApp("app.R")
```

### 问题: 数据加载失败

```r
# 原因: 数据文件路径错误
# 解决:

# 1. 检查文件是否存在
csv_path <- "/Users/xiongyi/Desktop/Airbnb/listings (3).csv"
file.exists(csv_path)

# 2. 检查文件权限
file.access(csv_path, 4)  # 0 = 可读

# 3. 检查文件格式
head(read.csv(csv_path, nrows = 1))
```

### 问题: 应用运行缓慢

```r
# 解决:
# 1. 关闭其他应用释放内存
# 2. 使用较小的数据集进行测试
# 3. 检查网络连接

# 检查内存使用
gc()  # 垃圾回收

# 查看详细信息
sessionInfo()
```

---

## ✅ 完整检查清单

在使用应用前，检查以下项：

### 软件
- [ ] R 4.0+已安装
- [ ] RStudio已安装
- [ ] 所有包已安装成功
- [ ] 没有包冲突或错误

### 数据
- [ ] listings (3).csv文件存在
- [ ] 文件位置正确
- [ ] 文件可读
- [ ] 文件格式正确

### 应用
- [ ] app.R文件存在
- [ ] 所有R模块存在 (R/00到03)
- [ ] 工作目录正确
- [ ] 没有语法错误

### 环境
- [ ] 网络连接正常
- [ ] 充足的磁盘空间
- [ ] 充足的内存 (4GB+)
- [ ] 浏览器已安装并可用

---

## 🎓 安装完成后

### 立即尝试
1. 运行应用
2. 查看市场分析数据
3. 尝试预测工具
4. 获取定价建议

### 进一步学习
1. 阅读 START_HERE.md
2. 阅读 README.md
3. 运行 examples.R
4. 查看代码注释

### 自定义应用
1. 修改模型参数 (02_predictive_models.R)
2. 更改UI样式 (app.R)
3. 添加新的分析维度 (01_descriptive_analysis.R)
4. 自定义定价策略 (03_pricing_engine.R)

---

## 📞 获取帮助

遇到问题? 按以下顺序查看：

1. **本文件** - INSTALLATION_GUIDE.md
2. **START_HERE.md** - 快速入门
3. **QUICKSTART.md** - 详细启动步骤
4. **README.md** - 完整文档
5. **代码注释** - 查看.R文件中的注释

---

## 🚀 下一步

安装完成后：

```r
# 1. 启动应用
launch_airbnb_app()

# 2. 运行示例
source("examples.R")

# 3. 查看模型性能
source("R/02_predictive_models.R")
get_feature_importance()
```

---

## ✨ 安装完成!

恭喜! 现在你可以：

✅ 查看市场分析  
✅ 预测房产表现  
✅ 获取定价建议  
✅ 导出分析结果  

**开始使用吧!** 🎉

---

## 📋 版本信息

**应用版本**: 1.0
**R版本要求**: 4.0+
**Shiny版本**: 1.7+
**最后更新**: 2024年11月
**维护状态**: ✅ 活跃

---

*有任何问题欢迎反馈！祝你使用愉快!*


