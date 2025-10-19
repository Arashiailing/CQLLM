/**
 * @deprecated
 * @name Mostly duplicate module
 * @description There is another file that shares a lot of the code with this file. Merge the two files to improve maintainability.
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
 * @id py/mostly-duplicate-file
 */

import python

// 从模块 `m`、`other` 和字符串 `message` 中选择数据，其中没有过滤条件。
from Module m, Module other, string message
where none()
select m, message, other, other.getName()
