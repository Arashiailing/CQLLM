/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 引入Python模块，用于执行Python代码分析相关的查询
import python
// 引入外部版本控制（VCS）模块，用于访问版本控制系统相关的功能
import external.VCS

// 从Commit类和File类中提取数据
from Commit commit, File sourceFile
// 筛选条件：文件来源于源代码且该文件是提交影响范围内的文件
where sourceFile.fromSource() and sourceFile = commit.getAnAffectedFile()
// 输出提交的修订版本号及对应的源文件
select commit.getRevisionName(), sourceFile