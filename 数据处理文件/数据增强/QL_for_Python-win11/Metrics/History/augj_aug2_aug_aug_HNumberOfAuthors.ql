/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 引入Python语言分析库，提供Python代码结构的解析功能
import python
// 引入外部版本控制系统接口，用于获取文件的版本历史和作者数据
import external.VCS

// 定义Python模块变量，表示当前分析的Python文件
from Module pythonModule

// 筛选条件：仅处理那些可以计算代码行数的Python模块
where exists(pythonModule.getMetrics().getNumberOfLinesOfCode())

// 计算并返回每个Python模块对应的唯一代码提交者数量
select pythonModule, count(Author commitAuthor | commitAuthor.getAnEditedFile() = pythonModule.getFile())