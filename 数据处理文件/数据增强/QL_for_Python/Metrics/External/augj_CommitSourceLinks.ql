/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 导入Python代码分析相关的库
import python
// 导入版本控制系统(VCS)相关的库
import external.VCS

// 从提交记录和文件中查询数据
from Commit commit, File file
// 筛选条件：文件来源于源代码且该文件受提交影响
where file.fromSource() and 
      file = commit.getAnAffectedFile()
// 输出提交的修订版本号和相关文件
select commit.getRevisionName(), file