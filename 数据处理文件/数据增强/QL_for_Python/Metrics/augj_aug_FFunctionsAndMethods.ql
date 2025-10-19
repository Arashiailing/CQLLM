/**
 * @name Functions and methods per file
 * @description Provides a count of functions and methods contained within each file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 引入Python分析模块，支持代码结构解析

from Module sourceModule, int funcQuantity
// 定义计算条件：统计每个源模块中排除lambda函数后的函数总数
where funcQuantity = count(Function funcItem | 
       funcItem.getEnclosingModule() = sourceModule and 
       funcItem.getName() != "lambda")
// 输出结果：模块对象及其函数计数，按函数数量从高到低排序
select sourceModule, funcQuantity order by funcQuantity desc