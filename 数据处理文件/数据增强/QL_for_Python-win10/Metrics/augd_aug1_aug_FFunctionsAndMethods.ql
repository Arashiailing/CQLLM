/**
 * @name File-level function and method count
 * @description Provides a count of all functions and methods defined in each Python file/module.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入Python分析模块，用于解析代码结构

// 定义要统计的Python文件模块及其包含的函数数量
from Module fileModule, int funcCount
// 计算每个模块中的函数总数，排除lambda表达式
where funcCount = count(Function method | 
       method.getEnclosingModule() = fileModule and 
       method.getName() != "lambda")
// 输出模块路径及其函数数量，按数量从高到低排序
select fileModule, funcCount order by funcCount desc