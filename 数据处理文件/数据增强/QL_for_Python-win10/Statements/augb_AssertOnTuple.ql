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

// 从程序中提取所有断言语句，并检查其测试对象是否为元组类型。
from Assert assertionStmt, string truthValue, string prefixStr
where
  // 获取断言语句的测试对象，并检查其是否为Tuple实例。
  assertionStmt.getTest() instanceof Tuple and
  (
    // 如果元组中有元素存在，则设置truthValue为"True"和prefixStr为"non-"。
    if exists(assertionStmt.getTest().(Tuple).getAnElt())
    then (
      truthValue = "True" and prefixStr = "non-"
    ) else (
      // 如果元组为空，则设置truthValue为"False"和prefixStr为空字符串。
      truthValue = "False" and prefixStr = ""
    )
  )
// 选择断言语句，并生成描述性消息。
select assertionStmt, "Assertion of " + prefixStr + "empty tuple is always " + truthValue + "."