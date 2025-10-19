/**
 * @name Display strings of commits
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // 导入Python语言分析模块，支持Python代码的静态语义分析
import external.VCS  // 导入外部版本控制系统模块，提供版本控制历史和提交记录的访问接口

// 查询范围：从版本控制系统中提取所有提交记录
from Commit commitEntry

// 输出格式：提交修订ID和格式化的提交信息（含日期）
select 
    commitEntry.getRevisionName(), 
    commitEntry.getMessage() + "(" + commitEntry.getDate().toString() + ")"