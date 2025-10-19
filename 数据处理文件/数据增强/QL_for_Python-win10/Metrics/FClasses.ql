/**
 * @name Classes per file
 * @description Measures the number of classes in a file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// 从模块 `m` 和整数 `n` 中导入数据，其中 `n` 是模块 `m` 中类的数量
from Module m, int n
// 条件：`n` 等于模块 `m` 中的类的数量
where n = count(Class c | c.getEnclosingModule() = m)
// 选择模块 `m` 和类的数量 `n`，并按 `n` 降序排列
select m, n order by n desc
