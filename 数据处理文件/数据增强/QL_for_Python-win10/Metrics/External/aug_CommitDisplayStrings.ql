/**
 * @name Display strings of commits
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // 导入Python语言分析库，用于Python代码语义分析
import external.VCS  // 导入外部版本控制库，提供版本历史和提交记录访问能力

// 查询范围：从版本控制系统中提取所有提交记录
from Commit commitRecord
// 构造输出结果：包含提交修订ID和格式化的提交信息（含日期）
select 
    commitRecord.getRevisionName(), 
    commitRecord.getMessage() + "(" + commitRecord.getDate().toString() + ")"