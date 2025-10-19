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

import python // 导入python模块，用于处理Python代码

// 从Module m和整数n中选择数据
from Module m, int n
// 其中n是满足以下条件的函数数量：
where n = count(Function f | f.getEnclosingModule() = m and f.getName() != "lambda")
// 选择模块m和对应的函数数量n，并按n降序排列
select m, n order by n desc
