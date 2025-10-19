import python

// 定义查询变量：描述性消息、统计计数和排序标识符
from string description, int metricValue, int sortOrder
where
  // === 代码库基础统计 ===
  (
    // 统计数据库中所有模块的代码行数（排序标识符：0）
    sortOrder = 0 and
    description = "Lines of code in DB" and
    metricValue = sum(Module m | | m.getMetrics().getNumberOfLinesOfCode())
  )
  or
  (
    // 统计仓库中所有模块的代码行数（排序标识符：1）
    sortOrder = 1 and
    description = "Lines of code in repo" and
    metricValue =
      sum(Module m | exists(m.getFile().getRelativePath()) | m.getMetrics().getNumberOfLinesOfCode())
  )
  or
  (
    // 统计项目中的文件总数（排序标识符：2）
    sortOrder = 2 and
    description = "Files" and
    metricValue = count(File f)
  )
  or
  // === 分隔符 ===
  (
    sortOrder = 10 and description = "----------" and metricValue = 0
  )
  or
  // === 结构化元素统计 ===
  (
    // 统计模块数量（排序标识符：11）
    sortOrder = 11 and
    description = "Modules" and
    metricValue = count(Module m)
  )
  or
  (
    // 统计类定义数量（排序标识符：12）
    sortOrder = 12 and
    description = "Classes" and
    metricValue = count(Class c)
  )
  or
  (
    // 统计函数定义数量（排序标识符：13）
    sortOrder = 13 and
    description = "Functions" and
    metricValue = count(Function f)
  )
  or
  (
    // 统计异步函数数量（排序标识符：14）
    sortOrder = 14 and
    description = "async functions" and
    metricValue = count(Function f | f.isAsync())
  )
  or
  (
    // 统计包含可变位置参数(*args)的函数数量（排序标识符：15）
    sortOrder = 15 and
    description = "*args params" and
    metricValue = count(Function f | f.hasVarArg())
  )
  or
  (
    // 统计包含可变关键字参数(**kwargs)的函数数量（排序标识符：16）
    sortOrder = 16 and
    description = "**kwargs params" and
    metricValue = count(Function f | f.hasKwArg())
  )
  or
  // === 分隔符 ===
  (
    sortOrder = 20 and description = "----------" and metricValue = 0
  )
  or
  // === 语句和表达式统计 ===
  (
    // 统计函数调用表达式数量（排序标识符：21）
    sortOrder = 21 and
    description = "call" and
    metricValue = count(Call c)
  )
  or
  (
    // 统计for循环语句数量（排序标识符：22）
    sortOrder = 22 and
    description = "for loop" and
    metricValue = count(For f)
  )
  or
  (
    // 统计列表/字典/集合推导式数量（排序标识符：23）
    sortOrder = 23 and
    description = "comprehension" and
    metricValue = count(Comp c)
  )
  or
  (
    // 统计属性访问表达式数量（排序标识符：24）
    sortOrder = 24 and
    description = "attribute" and
    metricValue = count(Attribute a)
  )
  or
  (
    // 统计赋值语句数量（排序标识符：25）
    sortOrder = 25 and
    description = "assignment" and
    metricValue = count(Assign a)
  )
  or
  (
    // 统计await表达式数量（排序标识符：26）
    sortOrder = 26 and
    description = "await" and
    metricValue = count(Await a)
  )
  or
  (
    // 统计yield表达式数量（排序标识符：27）
    sortOrder = 27 and
    description = "yield" and
    metricValue = count(Yield y)
  )
  or
  (
    // 统计with语句数量（排序标识符：28）
    sortOrder = 28 and
    description = "with" and
    metricValue = count(With w)
  )
  or
  (
    // 统计raise语句数量（排序标识符：29）
    sortOrder = 29 and
    description = "raise" and
    metricValue = count(Raise r)
  )
  or
  (
    // 统计return语句数量（排序标识符：30）
    sortOrder = 30 and
    description = "return" and
    metricValue = count(Return r)
  )
  or
  (
    // 统计match语句数量（Python 3.10+特性，排序标识符：31）
    sortOrder = 31 and
    description = "match" and
    metricValue = count(MatchStmt m)
  )
  or
  // === 导入语句统计 ===
  (
    // 统计from ... import ...语句数量（排序标识符：32）
    sortOrder = 32 and
    description = "from ... import ..." and
    metricValue = count(Import i | i.isFromImport())
  )
  or
  (
    // 统计import ...语句数量（排序标识符：33）
    sortOrder = 33 and
    description = "import ..." and
    metricValue = count(Import i | not i.isFromImport())
  )
  or
  (
    // 统计import *语句数量（排序标识符：34）
    sortOrder = 34 and
    description = "import *" and
    metricValue = count(ImportStar i)
  )
select sortOrder, description, metricValue order by sortOrder