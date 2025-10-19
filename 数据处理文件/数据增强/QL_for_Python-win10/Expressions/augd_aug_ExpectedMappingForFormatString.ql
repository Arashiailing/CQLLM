/**
 * @name Formatted object is not a mapping
 * @description Detects cases where a % formatting operation uses a named specifier in the format string
 *              but provides a non-mapping object as the right operand, which would raise a TypeError.
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

// This query identifies Python code where the % formatting operator is used with a format string
// containing named specifiers (e.g., "%(name)s"), but the right operand is not a mapping type
// (like dict or similar). This will cause a TypeError at runtime.
from Expr rhsOperand, ClassValue rhsClass
where
  // There exists a binary expression using the % operator for string formatting
  exists(BinaryExpr formatOperation |
    // The operator must be the modulo operator (%)
    formatOperation.getOp() instanceof Mod and
    // Extract the right operand which should be the data source for formatting
    rhsOperand = formatOperation.getRight() and
    // The left operand must be a valid format string
    format_string(formatOperation.getLeft()) and
    // The format string must contain named specifiers (e.g., %(key)s)
    mapping_format(formatOperation.getLeft()) and
    // Get the class of the right operand to check its type
    rhsOperand.pointsTo().getClass() = rhsClass and
    // The right operand's class must not be a mapping type
    not rhsClass.isMapping()
  )
select rhsOperand, "Right hand side of a % operator must be a mapping, not class $@.", rhsClass, rhsClass.getName()