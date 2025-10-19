/**
 * @name Formatted object is not a mapping
 * @description Detects % formatting operations where the format string contains named specifiers 
 *              but the right operand is not a mapping type. This causes a TypeError at runtime.
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

// Identify expressions where % formatting uses named specifiers with non-mapping right operand
from Expr rhsExpr, ClassValue rhsClass
where
  // Locate % formatting expressions with named specifiers in format string
  exists(BinaryExpr formatOp | 
    formatOp.getOp() instanceof Mod and          // Uses % operator
    rhsExpr = formatOp.getRight() and            // Target right operand
    format_string(formatOp.getLeft()) and        // Left operand is format string
    mapping_format(formatOp.getLeft())           // Format string contains named specifiers
  ) and
  // Verify right operand's class is not a mapping type
  rhsExpr.pointsTo().getClass() = rhsClass and
  not rhsClass.isMapping()
select rhsExpr, "Right hand side of a % operator must be a mapping, not class $@.", rhsClass, rhsClass.getName()