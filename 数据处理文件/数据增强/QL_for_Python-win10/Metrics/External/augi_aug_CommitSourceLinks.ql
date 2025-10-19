/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

import python
import external.VCS

// 提取提交记录及其关联的源代码文件
from Commit commit, File sourceFile
// 筛选条件：文件必须是源代码文件且受提交影响
where sourceFile.fromSource() 
  and sourceFile = commit.getAnAffectedFile()
// 输出提交修订标识符和受影响的源代码文件
select commit.getRevisionName(), sourceFile