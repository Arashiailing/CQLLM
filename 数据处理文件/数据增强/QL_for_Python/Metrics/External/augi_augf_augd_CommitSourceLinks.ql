/**
 * @name 源代码提交链接
 * @kind source-link
 * @id py/commit-source-links
 * @metricType commit
 */

// 引入Python代码分析功能模块
import python
// 导入版本控制系统集成模块，用于获取提交历史信息
import external.VCS

// 定义查询变量：代表代码提交的修订和源文件对象
from Commit codeCommit, File sourceFile
// 设定筛选条件：
// 1. 源文件必须是原始代码（非自动生成）
where sourceFile.fromSource()
// 2. 源文件必须被当前提交所影响
and sourceFile = codeCommit.getAnAffectedFile()
// 返回结果：提交的修订版本号和对应的源文件
select codeCommit.getRevisionName(), sourceFile