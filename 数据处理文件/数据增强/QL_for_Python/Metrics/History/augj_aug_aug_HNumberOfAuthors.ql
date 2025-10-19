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
// 导入外部版本控制系统(VCS)模块，用于追踪代码历史变更记录
import external.VCS

// 定义主查询：针对每个Python模块，计算其唯一贡献者数量
from Module pythonModule
// 应用过滤条件：仅考虑那些具有可计算代码行数的Python模块
where exists(pythonModule.getMetrics().getNumberOfLinesOfCode())
// 提取文件作者关联：定义文件与作者之间的关系
select pythonModule, count(Author fileAuthor | 
  // 筛选条件：找出所有编辑过当前文件(模块)的作者
  fileAuthor.getAnEditedFile() = pythonModule.getFile()
)