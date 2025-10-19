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
from Expr rightOperand, ClassValue rightOperandClass
where
  // Identify a % formatting expression
  exists(BinaryExpr formatExpr | 
    // Confirm it's a % operator
    formatExpr.getOp() instanceof Mod and
    
    // Get the right operand expression
    rightOperand = formatExpr.getRight() and
    
    // Verify the left side is a format string
    format_string(formatExpr.getLeft()) and
    
    // Confirm the format string contains named specifiers
    mapping_format(formatExpr.getLeft()) and
    
    // Get the class of the right operand
    rightOperand.pointsTo().getClass() = rightOperandClass and
    
    // Check if the class is not a mapping type
    not rightOperandClass.isMapping()
  )
select rightOperand, "Right hand side of a % operator must be a mapping, not class $@.", rightOperandClass, rightOperandClass.getName()