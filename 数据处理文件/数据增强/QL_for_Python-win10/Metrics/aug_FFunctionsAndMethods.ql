/**
 * @name Functions and methods per file
 * @description Measures the number of functions and methods in a file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入Python模块，用于代码结构分析

// 查询每个模块中包含的函数数量
from Module moduleContainer, int methodCount
// 计算条件：统计模块内所有非lambda函数的数量
where methodCount = count(Function method | 
       method.getEnclosingModule() = moduleContainer and 
       method.getName() != "lambda")
// 输出模块及其函数计数，按函数数量降序排列
select moduleContainer, methodCount order by methodCount desc