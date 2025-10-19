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

// 查询目标：分析每个Python模块中的函数密度
from Module sourceModule, int functionCount
// 计算逻辑：统计模块中定义的所有常规函数（排除lambda表达式）
where functionCount = count(Function function | 
       // 关联条件：函数必须属于当前模块
       function.getEnclosingModule() = sourceModule and 
       // 过滤条件：排除匿名lambda函数
       function.getName() != "lambda")
// 结果输出：展示模块及其函数计数，按函数数量降序排列
select sourceModule, functionCount order by functionCount desc