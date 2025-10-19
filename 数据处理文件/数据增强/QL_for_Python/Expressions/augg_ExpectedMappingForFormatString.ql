/**
 * @name Formatted object is not a mapping
 * @description Detects cases where a format string contains named specifiers but the right-hand operand is not a mapping object, which would cause a TypeError.
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

// Identify expressions that are right-hand operands of % formatting operations
// where the format string requires a mapping but the operand is not a mapping type
from BinaryExpr formatOperation, Expr rhsOperand, ClassValue operandClass
where
  // The operation must be a string formatting (% operator)
  formatOperation.getOp() instanceof Mod and
  // Left operand must be a valid format string
  format_string(formatOperation.getLeft()) and
  // Format string contains named specifiers requiring a mapping
  mapping_format(formatOperation.getLeft()) and
  // Capture the right-hand operand
  rhsOperand = formatOperation.getRight() and
  // Get the actual class of the right-hand operand
  rhsOperand.pointsTo().getClass() = operandClass and
  // Verify the operand's class is not a mapping type
  not operandClass.isMapping()
select rhsOperand, 
  "Right-hand side of % operator must be a mapping when format contains named specifiers, not class $@.", 
  operandClass, operandClass.getName()