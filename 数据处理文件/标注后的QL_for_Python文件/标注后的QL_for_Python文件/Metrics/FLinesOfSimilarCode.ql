/**
 * @deprecated
 * @name Similar lines in files
 * @description The number of lines in a file, including code, comment and whitespace lines,
 *              which are similar in at least one other place.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python // 导入python库，用于处理Python代码相关的查询

// 定义一个查询，从文件和整数对中选择数据
from File f, int n
where none() // 条件为none()，表示没有过滤条件
select f, n order by n desc // 选择文件f和整数n，并按n的降序排列结果
