/**
 * @name Testing equality to None
 * @description Testing whether an object is 'None' using the == operator is inefficient and potentially incorrect.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// 从Compare类中选择比较操作符为==且其中一个比较对象为None的实例
from Compare c
where c.getOp(0) instanceof Eq and c.getAComparator() instanceof None
select c, "Testing for None should use the 'is' operator." // 选择这些实例并给出建议使用'is'操作符进行比较
