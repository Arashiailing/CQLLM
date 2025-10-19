/**
 * @deprecated
 * @name File line count analysis
 * @description Basic query that selects files and associates them with numeric values.
 *              This is a template implementation without actual similarity metrics.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python // 导入python库，用于处理Python代码分析

// 定义文件源和行数量变量
from File sourceFile, int lineQuantity
// 不应用任何过滤条件（保持原始逻辑）
where none()
// 输出文件对象和行数量，按行数量降序排序
select sourceFile, lineQuantity order by lineQuantity desc