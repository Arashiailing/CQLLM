/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 导入Python语言分析模块，用于解析Python代码结构
import python
// 导入版本控制外部模块，用于访问代码历史记录和作者信息
import external.VCS

// 查询逻辑：识别每个Python模块的唯一作者数量
from Module pythonModule
// 筛选条件：只考虑包含可度量代码行数的Python模块
where exists(pythonModule.getMetrics().getNumberOfLinesOfCode())
// 结果输出：返回模块及其对应的唯一作者计数
select pythonModule, count(Author fileAuthor | fileAuthor.getAnEditedFile() = pythonModule.getFile())