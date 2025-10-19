/**
 * @name Formatted object is not a mapping
 * @description Detects when a format string with named specifiers is used with a non-mapping operand
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

from Expr rhsOperand, ClassValue targetClass, BinaryExpr formatExpression
where
  formatExpression.getOp() instanceof Mod and
  format_string(formatExpression.getLeft()) and
  mapping_format(formatExpression.getLeft()) and
  rhsOperand = formatExpression.getRight() and
  rhsOperand.pointsTo().getClass() = targetClass and
  not targetClass.isMapping()
select rhsOperand, "Right hand side of a % operator must be a mapping, not class $@.", targetClass, targetClass.getName()