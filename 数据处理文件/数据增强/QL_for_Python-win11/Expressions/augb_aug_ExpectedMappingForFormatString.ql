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

// 检测使用%格式化时，格式字符串包含命名规范符但右侧操作数不是映射类型的错误情况
from Expr rhsExpression, ClassValue rhsClass
where
  // 识别使用%操作符的格式化表达式
  exists(BinaryExpr formatOperation | 
    formatOperation.getOp() instanceof Mod and  // 确认是%操作符
    rhsExpression = formatOperation.getRight() and  // 获取右侧操作数表达式
    format_string(formatOperation.getLeft()) and  // 验证左侧是格式字符串
    mapping_format(formatOperation.getLeft()) and  // 确认格式字符串包含命名规范符
    rhsExpression.pointsTo().getClass() = rhsClass and  // 获取右侧操作数的类型
    not rhsClass.isMapping()  // 检查该类型是否不是映射类型
  )
select rhsExpression, "Right hand side of a % operator must be a mapping, not class $@.", rhsClass, rhsClass.getName()