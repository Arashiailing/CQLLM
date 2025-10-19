/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 导入Python库，用于处理Python代码相关的查询
import python
// 导入外部版本控制系统（VCS）库，用于处理与版本控制相关的查询
import external.VCS

// 从Commit类和File类中选择数据
from Commit c, File f
// 条件：文件来自源代码并且文件是提交所影响的文件之一
where f.fromSource() and f = c.getAnAffectedFile()
// 选择提交的修订名称和文件
select c.getRevisionName(), f
