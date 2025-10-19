/**
 * @name Commit information display
 * @description Presents detailed commit information from version control system,
 *              including unique revision identifiers and commit messages with timestamps.
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // 引入Python模块，支持Python代码分析功能
import external.VCS  // 引入外部版本控制模块，提供版本控制系统数据访问能力

// 查询版本控制系统中的所有提交记录
from Commit commitRecord

// 格式化输出：第一列为提交的唯一修订标识符，
// 第二列为提交消息与提交日期的组合字符串
select commitRecord.getRevisionName(), commitRecord.getMessage() + "(" + commitRecord.getDate().toString() + ")"