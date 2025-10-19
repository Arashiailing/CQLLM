/**
 * @name File-level function and method count
 * @description Calculates the total count of functions and methods within each Python file/module.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入Python模块，用于代码结构分析

// 查询每个源模块中包含的函数数量
from Module sourceModule, int functionCount
// 计算条件：统计模块内所有非lambda函数的数量
where functionCount = count(Function func | 
       func.getEnclosingModule() = sourceModule and 
       func.getName() != "lambda")
// 输出模块及其函数计数，按函数数量降序排列
select sourceModule, functionCount order by functionCount desc