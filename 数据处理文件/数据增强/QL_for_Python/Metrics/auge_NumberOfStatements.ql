/**
 * @name Number of statements
 * @description The number of statements in this module
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入Python语言库，用于代码分析

// 查询每个模块及其包含的语句数量
from Module mod
// 计算每个模块中的语句总数
select mod, count(Stmt statement | statement.getEnclosingModule() = mod) as statementCount 
order by statementCount desc