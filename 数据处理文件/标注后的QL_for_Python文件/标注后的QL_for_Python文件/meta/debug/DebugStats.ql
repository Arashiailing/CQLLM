import python

// 从数据库中导入模块，并定义查询参数：消息字符串、计数和排序值
from string msg, int cnt, int sort
where
  // 当排序值为0时，计算数据库中的代码行数
  sort = 0 and
  msg = "Lines of code in DB" and
  cnt = sum(Module m | | m.getMetrics().getNumberOfLinesOfCode())
  or
  // 当排序值为1时，计算仓库中的代码行数
  sort = 1 and
  msg = "Lines of code in repo" and
  cnt =
    sum(Module m | exists(m.getFile().getRelativePath()) | m.getMetrics().getNumberOfLinesOfCode())
  or
  // 当排序值为2时，计算文件数量
  sort = 2 and
  msg = "Files" and
  cnt = count(File f)
  or
  // 当排序值为10时，插入分隔符
  sort = 10 and msg = "----------" and cnt = 0
  or
  // 当排序值为11时，计算模块数量
  sort = 11 and
  msg = "Modules" and
  cnt = count(Module m)
  or
  // 当排序值为12时，计算类的数量
  sort = 12 and
  msg = "Classes" and
  cnt = count(Class c)
  or
  // 当排序值为13时，计算函数的数量
  sort = 13 and
  msg = "Functions" and
  cnt = count(Function f)
  or
  // 当排序值为14时，计算异步函数的数量
  sort = 14 and
  msg = "async functions" and
  cnt = count(Function f | f.isAsync())
  or
  // 当排序值为15时，计算带有*args参数的函数数量
  sort = 15 and
  msg = "*args params" and
  cnt = count(Function f | f.hasVarArg())
  or
  // 当排序值为16时，计算带有**kwargs参数的函数数量
  sort = 16 and
  msg = "**kwargs params" and
  cnt = count(Function f | f.hasKwArg())
  or
  // 当排序值为20时，插入分隔符
  sort = 20 and msg = "----------" and cnt = 0
  or
  // 当排序值为21时，计算调用语句的数量
  sort = 21 and
  msg = "call" and
  cnt = count(Call c)
  or
  // 当排序值为22时，计算for循环的数量
  sort = 22 and
  msg = "for loop" and
  cnt = count(For f)
  or
  // 当排序值为23时，计算列表解析的数量
  sort = 23 and
  msg = "comprehension" and
  cnt = count(Comp c)
  or
  // 当排序值为24时，计算属性访问的数量
  sort = 24 and
  msg = "attribute" and
  cnt = count(Attribute a)
  or
  // 当排序值为25时，计算赋值操作的数量
  sort = 25 and
  msg = "assignment" and
  cnt = count(Assign a)
  or
  // 当排序值为26时，计算await表达式的数量
  sort = 26 and
  msg = "await" and
  cnt = count(Await a)
  or
  // 当排序值为27时，计算yield表达式的数量
  sort = 27 and
  msg = "yield" and
  cnt = count(Yield y)
  or
  // 当排序值为28时，计算with语句的数量
  sort = 28 and
  msg = "with" and
  cnt = count(With w)
  or
  // 当排序值为29时，计算raise语句的数量
  sort = 29 and
  msg = "raise" and
  cnt = count(Raise r)
  or
  // 当排序值为30时，计算return语句的数量
  sort = 30 and
  msg = "return" and
  cnt = count(Return r)
  or
  // 当排序值为31时，计算match语句的数量
  sort = 31 and
  msg = "match" and
  cnt = count(MatchStmt m)
  or
  // 当排序值为32时，计算from ... import ...语句的数量
  sort = 32 and
  msg = "from ... import ..." and
  cnt = count(Import i | i.isFromImport())
  or
  // 当排序值为33时，计算import ...语句的数量
  sort = 33 and
  msg = "import ..." and
  cnt = count(Import i | not i.isFromImport())
  or
  // 当排序值为34时，计算import *语句的数量
  sort = 34 and
  msg = "import *" and
  cnt = count(ImportStar i)
select sort, msg, cnt order by sort
