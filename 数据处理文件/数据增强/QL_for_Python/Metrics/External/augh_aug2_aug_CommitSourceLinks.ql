/**
 * @name Source links of commits
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 导入Python语言分析模块，提供Python代码解析和语义分析能力
import python
// 导入版本控制系统集成模块，用于访问代码提交历史和变更追踪功能
import external.VCS

// 查询代码库中所有提交记录及其关联的源代码文件变更情况
from Commit codeCommit, File affectedSourceCode
where 
  // 筛选条件：仅处理源代码文件，排除测试、文档和配置文件等非源代码文件
  affectedSourceCode.fromSource() and
  // 关联条件：验证文件确实在当前提交中被修改、添加或删除
  affectedSourceCode = codeCommit.getAnAffectedFile()
// 输出结果：返回提交的唯一修订标识符及其影响的源代码文件路径
select codeCommit.getRevisionName(), affectedSourceCode