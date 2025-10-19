/**
 * @name Commit information display
 * @description Presents detailed commit information from version control system,
 *              including unique revision identifiers and commit messages with timestamps.
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // 导入Python模块以支持Python代码分析功能
import external.VCS  // 导入外部版本控制模块以提供版本控制系统数据访问能力

// 从版本控制系统中获取所有提交记录
from Commit commitData

// 格式化输出：第一列显示提交的唯一修订标识符，
// 第二列显示提交消息与提交日期的组合信息
select 
  commitData.getRevisionName(), 
  commitData.getMessage() + "(" + commitData.getDate().toString() + ")"