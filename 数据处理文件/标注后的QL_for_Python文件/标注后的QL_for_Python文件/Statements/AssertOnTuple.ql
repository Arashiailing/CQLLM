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
from Assert a, string b, string non
where
  // 获取断言语句的测试对象，并检查其是否为Tuple实例。
  a.getTest() instanceof Tuple and
  (
    // 如果元组中有元素存在，则设置b为"True"和non为"non-"。
    if exists(a.getTest().(Tuple).getAnElt())
    then (
      b = "True" and non = "non-"
    ) else (
      // 如果元组为空，则设置b为"False"和non为空字符串。
      b = "False" and non = ""
    )
  )
// 选择断言语句，并生成描述性消息。
select a, "Assertion of " + non + "empty tuple is always " + b + "."
