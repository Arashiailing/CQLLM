/**
 * @name Formatted object is not a mapping
 * @description Detects when a % formatting operation uses named specifiers in the format string 
 *              but the right operand is not a mapping type, which would cause a TypeError.
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

// 查找使用%格式化但右侧操作数不是映射类型的错误情况
from Expr rightOperand, ClassValue rightOperandClass
where
  // 确认存在使用%操作符的格式化表达式
  exists(BinaryExpr formatExpr | 
    formatExpr.getOp() instanceof Mod and  // 确认是%操作符
    rightOperand = formatExpr.getRight() and  // 获取右侧操作数表达式
    
    // 验证左侧是格式字符串且包含命名规范符
    format_string(formatExpr.getLeft()) and
    mapping_format(formatExpr.getLeft()) and
    
    // 获取右侧操作数的类型
    rightOperand.pointsTo().getClass() = rightOperandClass and
    
    // 检查该类型是否不是映射类型
    not rightOperandClass.isMapping()
  )
select rightOperand, "Right hand side of a % operator must be a mapping, not class $@.", rightOperandClass, rightOperandClass.getName()