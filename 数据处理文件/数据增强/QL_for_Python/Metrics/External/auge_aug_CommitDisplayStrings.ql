/**
 * @name Version control commit information display
 * @description Retrieves and formats commit details from version control history
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // Python语言分析模块，提供代码语义分析能力
import external.VCS  // 外部版本控制系统接口，用于访问提交历史和元数据

// 查询目标：从版本控制系统中检索所有提交记录
from Commit commitEntry
// 输出格式：提交修订标识符和包含时间戳的格式化提交消息
select 
    commitEntry.getRevisionName(), 
    commitEntry.getMessage() + "(" + commitEntry.getDate().toString() + ")"