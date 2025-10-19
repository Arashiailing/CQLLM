/**
 * @name Module function and method enumeration
 * @description Provides a count of all functions and methods contained within each Python module/file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 引入Python分析模块，用于解析代码结构

// 查询目标：每个Python模块及其包含的函数数量
from Module pyModule, int funcCount
// 筛选条件：统计模块内所有非lambda函数的数量
where funcCount = count(Function func | 
       func.getEnclosingModule() = pyModule and 
       func.getName() != "lambda")
// 输出结果：按函数数量降序排列的模块列表
select pyModule, funcCount order by funcCount desc