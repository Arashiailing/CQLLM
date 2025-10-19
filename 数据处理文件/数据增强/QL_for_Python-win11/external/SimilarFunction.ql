/**
 * @deprecated
 * @name Similar function
 * @description There is another function that is very similar this one. Extract the common code to a common function to improve sharing.
 * @kind problem
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity low
 * @precision very-high
 * @id py/similar-function
 */

import python

// 从函数 m, 函数 other 和字符串 message 中选择数据
from Function m, Function other, string message
// 条件为空，即不过滤任何结果
where none()
// 选择函数 m, 消息 message, 其他函数 other 以及 other 函数的名称
select m, message, other, other.getName()
