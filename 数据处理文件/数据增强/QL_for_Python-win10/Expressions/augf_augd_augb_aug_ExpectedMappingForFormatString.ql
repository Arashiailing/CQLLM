/**
 * @name Formatted object is not a mapping
 * @description Detects cases where a % formatting operation uses named specifiers in the format string but provides a non-mapping object as the right operand, which would cause a TypeError at runtime.
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

// This query identifies Python % formatting expressions where the format string contains named specifiers (e.g., %(name)s)
// but the right operand is not a mapping type (like a dictionary), which would raise a TypeError at runtime.
from BinaryExpr formatOperation, Expr rhsValue, ClassValue rhsClass
where
  // Verify the expression uses % formatting operator
  formatOperation.getOp() instanceof Mod and
  
  // Extract the right-hand side operand
  rhsValue = formatOperation.getRight() and
  
  // Confirm left operand is a valid format string
  format_string(formatOperation.getLeft()) and
  
  // Check for named format specifiers in the string
  mapping_format(formatOperation.getLeft()) and
  
  // Determine the actual class of the right operand
  rhsValue.pointsTo().getClass() = rhsClass and
  
  // Ensure the class is not a mapping type
  not rhsClass.isMapping()
select rhsValue, "Right hand side of a % operator must be a mapping, not class $@.", rhsClass, rhsClass.getName()