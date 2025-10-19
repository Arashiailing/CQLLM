/**
 * @name Number of authors
 * @description Number of distinct authors for each file
 * @kind treemap
 * @id py/historical-number-of-authors
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg min max
 */

// 引入Python语言分析模块，提供代码解析功能
import python
// 引入版本控制系统接口，用于获取代码历史信息
import external.VCS

// 定义源文件变量，表示需要分析的Python源代码文件
from Module sourceFile
// 过滤条件：仅处理具有可度量代码行数的源文件
where exists(sourceFile.getMetrics().getNumberOfLinesOfCode())
// 计算每个源文件的唯一贡献者数量并返回结果
select sourceFile, count(Author codeContributor | codeContributor.getAnEditedFile() = sourceFile.getFile())