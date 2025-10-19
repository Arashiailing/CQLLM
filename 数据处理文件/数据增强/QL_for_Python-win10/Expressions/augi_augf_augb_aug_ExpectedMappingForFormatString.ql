/**
 * @name Formatted object is not a mapping
 * @description Detects cases where a format string with named specifiers is used with a non-mapping object as the right operand of the % operator.
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

// This query identifies % formatting operations where the format string contains named specifiers
// but the right operand is not a mapping type, which would cause a TypeError at runtime.
from Expr rhsOperand, ClassValue rhsOperandClass
where
  // Find a % formatting operation with named specifiers in the format string
  exists(BinaryExpr formatOperation | 
    formatOperation.getOp() instanceof Mod and
    rhsOperand = formatOperation.getRight() and
    format_string(formatOperation.getLeft()) and
    mapping_format(formatOperation.getLeft())
  ) and
  // Check that the right operand's type is not a mapping
  rhsOperand.pointsTo().getClass() = rhsOperandClass and
  not rhsOperandClass.isMapping()
select rhsOperand, "Right hand side of a % operator must be a mapping, not class $@.", rhsOperandClass, rhsOperandClass.getName()