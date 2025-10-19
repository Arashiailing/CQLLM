/**
 * @name Formatted object is not a mapping
 * @description The formatted object must be a mapping when the format includes a named specifier; otherwise a TypeError will be raised."
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

// 查找使用%格式化时，格式字符串包含命名规范符但右侧操作数不是映射类型的情况
from Expr rightOperand, ClassValue rightClass
where
  // 存在格式化表达式（使用%操作符）
  exists(BinaryExpr formatExpr | 
    formatExpr.getOp() instanceof Mod and  // 操作符是%
    rightOperand = formatExpr.getRight() and  // 右操作数是待检查对象
    format_string(formatExpr.getLeft()) and  // 左操作数是格式字符串
    mapping_format(formatExpr.getLeft()) and  // 格式字符串包含命名规范符
    rightOperand.pointsTo().getClass() = rightClass and  // 获取右操作数的类
    not rightClass.isMapping()  // 该类不是映射类型
  )
select rightOperand, "Right hand side of a % operator must be a mapping, not class $@.", rightClass, rightClass.getName()