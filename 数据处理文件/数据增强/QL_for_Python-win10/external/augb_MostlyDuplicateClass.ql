/**
 * @deprecated
 * @name Mostly duplicate class
 * @description Identifies classes where over 80% of methods are duplicated in another class. 
 *              Consider refactoring by creating a common supertype to enhance code reuse.
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

// 分析类实例 `sourceClass`、潜在重复类 `targetClass` 及描述信息
// 当前实现为占位逻辑，实际检测逻辑需后续补充
from Class sourceClass, Class targetClass, string description
where none()
select sourceClass, description, targetClass, targetClass.getName()