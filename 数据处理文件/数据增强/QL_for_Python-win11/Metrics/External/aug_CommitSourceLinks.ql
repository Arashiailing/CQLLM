/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 引入Python模块以支持Python代码分析功能
import python
// 引入外部版本控制系统模块，用于访问提交历史和文件变更信息
import external.VCS

// 从版本控制系统中提取提交记录及其关联的源代码文件
from Commit commitRecord, File affectedFile
// 确保我们只处理源代码文件
where affectedFile.fromSource()
// 并且该文件确实受到了提交的影响
and affectedFile = commitRecord.getAnAffectedFile()
// 输出结果：提交的修订标识符和受影响的源代码文件
select commitRecord.getRevisionName(), affectedFile