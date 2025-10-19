/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 导入Python语言分析支持库，用于解析Python代码结构
import python
// 导入外部版本控制模块，以访问文件的版本历史和作者信息
import external.VCS

// 定义文件模块变量，代表待分析的Python文件模块
from Module moduleFile
// 筛选条件：只考虑那些具有可计算代码行数的文件模块
where exists(moduleFile.getMetrics().getNumberOfLinesOfCode())
// 计算并返回每个文件模块对应的唯一代码提交者数量
select moduleFile, count(Author fileAuthor | fileAuthor.getAnEditedFile() = moduleFile.getFile())