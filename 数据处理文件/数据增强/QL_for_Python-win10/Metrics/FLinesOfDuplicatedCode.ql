/**
 * @deprecated  // 表示该查询已被弃用，不推荐使用。
 * @name Duplicated lines in files  // 查询名称：文件中的重复行数
 * @description The number of lines in a file, including code, comment and whitespace lines,
 *              which are duplicated in at least one other place.  // 描述：文件中的行数（包括代码、注释和空白行），这些行在至少一个其他位置被重复。
 * @kind treemap  // 查询类型：树状图
 * @treemap.warnOn highValues  // 当值较高时发出警告
 * @metricType file  // 度量类型：文件
 * @metricAggregate avg sum max  // 度量聚合方式：平均值、总和、最大值
 * @tags testability  // 标签：可测试性
 * @id py/duplicated-lines-in-files  // 查询ID：py/duplicated-lines-in-files
 */

import python  // 导入Python库

// 定义查询，选择文件f和重复行数n，并按n降序排列
from File f, int n
where none()  // 条件：无过滤条件
select f, n order by n desc  // 选择文件f和重复行数n，并按n降序排列
