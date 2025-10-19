/**
 * @name Formatted object is not a mapping
 * @description Detects cases where a format string with named specifiers is used with a non-mapping object on the right side of the % operator.
 *              This will cause a TypeError at runtime because named format specifiers require a mapping (like a dictionary) to extract values by name.
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

// This query identifies Python code where the % formatting operator is used with a format string containing named specifiers,
// but the right operand is not a mapping type (e.g., dict), which would cause a TypeError at runtime.
from Expr rightOperand, ClassValue rightOperandClass, BinaryExpr formatExpr
where
  // Identify a binary expression using the % operator for string formatting
  formatExpr.getOp() instanceof Mod and  // Confirm it's a % operator
  rightOperand = formatExpr.getRight() and  // Get the right operand expression
  
  // Verify the left operand is a format string with named specifiers
  format_string(formatExpr.getLeft()) and  // Check if left is a format string
  mapping_format(formatExpr.getLeft()) and  // Check if format string has named specifiers
  
  // Get the class of the right operand and verify it's not a mapping type
  rightOperand.pointsTo().getClass() = rightOperandClass and
  not rightOperandClass.isMapping()  // Ensure the class is not a mapping type
select rightOperand, "Right hand side of a % operator must be a mapping, not class $@.", rightOperandClass, rightOperandClass.getName()