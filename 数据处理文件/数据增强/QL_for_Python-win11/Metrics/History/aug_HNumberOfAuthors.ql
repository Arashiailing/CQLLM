/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 导入Python语言支持模块，提供代码解析及分析能力
import python
// 导入外部版本控制API，用于访问代码仓库历史数据
import external.VCS

// 定义文件模块变量，表示待分析的Python文件
from Module fileModule
// 筛选条件：仅考虑具有可度量代码行数的文件模块
where exists(fileModule.getMetrics().getNumberOfLinesOfCode())
// 计算并返回每个文件模块及其对应的唯一编辑者数量
select fileModule, count(Author fileAuthor | fileAuthor.getAnEditedFile() = fileModule.getFile())