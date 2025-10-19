/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 导入Python分析模块，提供Python代码解析能力
import python
// 导入版本控制系统集成模块，用于访问代码提交历史和变更追踪
import external.VCS

// 查询所有提交记录及其关联的源代码文件变更
from Commit commitEntry, File modifiedSourceFile
where 
  // 限定只处理源代码文件，排除测试、文档等非源代码文件
  modifiedSourceFile.fromSource() and
  // 确保文件确实在此次提交中被修改
  modifiedSourceFile = commitEntry.getAnAffectedFile()
// 返回提交的修订标识符与受影响的源代码文件
select commitEntry.getRevisionName(), modifiedSourceFile