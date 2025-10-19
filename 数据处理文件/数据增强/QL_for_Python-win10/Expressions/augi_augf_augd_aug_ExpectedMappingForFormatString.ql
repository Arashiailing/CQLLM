/**
 * @name Formatted object is not a mapping
 * @description Identifies instances where a % formatting operation employs named specifiers in the format string
 *              but supplies a non-mapping object as the right operand, leading to a TypeError at runtime.
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

// This query detects Python code that utilizes the % formatting operator with a format string
// containing named specifiers (e.g., "%(name)s"), where the right operand is not a mapping type
// (such as dict or similar). This scenario results in a runtime TypeError.
from Expr formatData, ClassValue dataType
where
  // Identify binary expressions with the % operator for string formatting
  exists(BinaryExpr binExpr |
    // Verify the operator is the modulo operator (%)
    binExpr.getOp() instanceof Mod and
    // Ensure the left operand is a valid format string with named specifiers
    format_string(binExpr.getLeft()) and
    mapping_format(binExpr.getLeft()) and
    // Extract the right operand serving as the data source for formatting
    formatData = binExpr.getRight()
  ) and
  // Obtain the class of the right operand for type checking
  formatData.pointsTo().getClass() = dataType and
  // Confirm the right operand's class is not a mapping type
  not dataType.isMapping()
select formatData, "Right hand side of a % operator must be a mapping, not class $@.", dataType, dataType.getName()