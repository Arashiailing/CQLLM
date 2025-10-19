/**
 * @name Number of statements
 * @description The number of statements in this module
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入Python语言库，用于分析Python代码

// 定义查询结果的返回类型，包括模块和语句数量
from Module m, int n
// 过滤条件：计算每个模块中的语句数量
where n = count(Stmt s | s.getEnclosingModule() = m)
// 选择模块和对应的语句数量，并按语句数量降序排列
select m, n order by n desc
