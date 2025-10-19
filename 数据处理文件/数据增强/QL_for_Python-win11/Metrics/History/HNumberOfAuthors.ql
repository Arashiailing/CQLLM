/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 导入python模块，用于处理Python代码的解析和分析
import python
// 导入外部版本控制系统（VCS）模块，用于访问提交历史记录等信息
import external.VCS

// 从Module类中选择文件模块m
from Module m
// 过滤条件：仅选择那些存在行数度量指标的文件模块
where exists(m.getMetrics().getNumberOfLinesOfCode())
// 选择文件模块m和编辑该文件的不同作者的数量
select m, count(Author author | author.getAnEditedFile() = m.getFile())
