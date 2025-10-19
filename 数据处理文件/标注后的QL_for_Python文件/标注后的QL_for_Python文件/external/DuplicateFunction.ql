/**
 * @deprecated
 * @name Duplicate function
 * @description There is another identical implementation of this function. Extract the code to a common file or superclass to improve sharing.
 * @kind problem
 * @tags testability
 *       useless-code
 *       maintainability
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/duplicate-function
 */

import python

// 从Function类中选择函数m和other，以及字符串message
from Function m, Function other, string message
// 过滤条件为空，即不进行任何过滤
where none()
// 选择要返回的字段：函数m、消息message、另一个函数other及其名称
select m, message, other, other.getName()
