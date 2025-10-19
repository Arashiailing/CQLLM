/**
 * @deprecated
 * @name File line count analyzer
 * @description Basic query for selecting files and associated line count metrics.
 *              Note: This is a simplified implementation without complex analysis logic.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python // 导入python库，用于处理Python代码相关的查询

// 定义查询变量
from File sourceFile, int metricValue

// 应用查询条件（此处无条件限制）
where none()

// 输出结果并排序
select sourceFile, metricValue order by metricValue desc