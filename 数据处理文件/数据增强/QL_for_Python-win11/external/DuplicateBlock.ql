/**
 * @name Duplicate code block
 * @description This block of code is duplicated elsewhere. If possible, the shared code should be refactored so there is only one occurrence left. It may not always be possible to address these issues; other duplicate code checks (such as duplicate function, duplicate class) give subsets of the results with higher confidence.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @deprecated
 * @precision medium
 * @id py/duplicate-block
 */

import python

// 从BasicBlock类中导入数据，并过滤掉所有不满足条件的数据
from BasicBlock d
where none()
// 选择符合条件的BasicBlock实例，并生成包含重复代码信息的字符串
select d, "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"
