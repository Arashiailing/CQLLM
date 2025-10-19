/**
 * @deprecated
 * @name Mostly duplicate class
 * @description More than 80% of the methods in this class are duplicated in another class. Create a common supertype to improve code sharing.
 * @kind problem
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mostly-duplicate-class
 */

import python

// 从类 `c`、类 `other` 和字符串 `message` 中选择数据，其中没有过滤条件。
from Class c, Class other, string message
where none()
select c, message, other, other.getName()
