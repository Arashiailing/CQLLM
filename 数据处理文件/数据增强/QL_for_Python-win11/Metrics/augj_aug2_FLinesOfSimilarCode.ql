/**
 * @deprecated
 * @name Similar lines in files
 * @description This query serves as a placeholder implementation for detecting
 *              potential code duplication across files. It selects files and
 *              assigns arbitrary integer metrics as a foundation for future
 *              similarity analysis implementation.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python // 导入python库，用于处理Python代码相关的查询

// 定义文件实体及其对应的度量值
from File fileEntity, int metricValue
where none() // 不应用任何过滤条件（保留原始逻辑）
select fileEntity, metricValue order by metricValue desc // 输出文件及其度量值，按度量值降序排列