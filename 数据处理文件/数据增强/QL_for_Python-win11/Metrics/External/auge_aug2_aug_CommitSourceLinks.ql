/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 * @description Identifies source code files modified in each commit, providing traceability
 *              between code changes and their corresponding commit revisions.
 */

// 导入Python语言分析模块，支持Python代码的解析与语义分析
import python
// 导入版本控制外部模块，用于访问代码仓库的提交历史与变更记录
import external.VCS

// 查询所有提交记录及其关联的源代码文件变更
from Commit commitRecord, File sourceFile
where 
  // 筛选源代码文件并确保其在提交中被修改
  sourceFile.fromSource() and
  sourceFile = commitRecord.getAnAffectedFile()
// 输出结果：提交的修订标识符与受影响的源代码文件路径
select commitRecord.getRevisionName(), sourceFile