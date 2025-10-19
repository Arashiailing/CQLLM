/**
 * @name Display strings of commits
 * @kind display-string
 * @id py/commit-display-strings
 * @metricType commit
 */

import python  // 导入Python库，用于处理Python代码的查询
import external.VCS  // 导入外部版本控制系统（VCS）库，用于处理版本控制相关的数据

// 从Commit类中选择数据
from Commit c
// 选择提交的修订名称和提交信息加上日期的字符串表示形式
select c.getRevisionName(), c.getMessage() + "(" + c.getDate().toString() + ")"
