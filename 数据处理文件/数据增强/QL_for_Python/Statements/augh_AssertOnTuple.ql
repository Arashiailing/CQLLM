/**
 * @name Asserting a tuple
 * @description Using an assert statement to test a tuple provides no validity checking.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-670
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/asserts-tuple
 */

import python

// 查找所有断言语句，其测试对象为元组类型
from Assert assertStmt, string truthValue, string nonEmptyPrefix
where
  // 确保断言语句的测试对象是一个元组
  assertStmt.getTest() instanceof Tuple and
  (
    // 检查元组是否包含元素
    if exists(assertStmt.getTest().(Tuple).getAnElt())
    then (
      // 非空元组的情况：断言结果为True，添加"non-"前缀
      truthValue = "True" and nonEmptyPrefix = "non-"
    ) else (
      // 空元组的情况：断言结果为False，无前缀
      truthValue = "False" and nonEmptyPrefix = ""
    )
  )
// 输出断言语句和相应的描述消息
select assertStmt, "Assertion of " + nonEmptyPrefix + "empty tuple is always " + truthValue + "."