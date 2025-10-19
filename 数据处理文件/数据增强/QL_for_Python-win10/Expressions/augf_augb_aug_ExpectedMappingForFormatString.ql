/**
 * @name Formatted object is not a mapping
 * @description The formatted object must be a mapping when the format includes a named specifier; otherwise a TypeError will be raised.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/not-mapping
 */

import python
import semmle.python.strings

// 查找使用%格式化时，格式字符串包含命名规范符但右侧操作数不是映射类型的错误情况
from Expr rightOperand, ClassValue rightOperandClass
where
  // 确认存在一个使用%操作符的格式化表达式
  exists(BinaryExpr formatExpr | 
    // 验证是%操作符
    formatExpr.getOp() instanceof Mod and
    // 获取右侧操作数表达式
    rightOperand = formatExpr.getRight() and
    // 验证左侧是格式字符串
    format_string(formatExpr.getLeft()) and
    // 确认格式字符串包含命名规范符
    mapping_format(formatExpr.getLeft())
  ) and
  // 获取右侧操作数的类型并检查是否不是映射类型
  rightOperand.pointsTo().getClass() = rightOperandClass and
  not rightOperandClass.isMapping()
select rightOperand, "Right hand side of a % operator must be a mapping, not class $@.", rightOperandClass, rightOperandClass.getName()