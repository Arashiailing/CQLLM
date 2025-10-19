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
from Expr dataObject, ClassValue objectClass
where
  // Find a binary expression using the % operator for string formatting
  exists(BinaryExpr formatExpr |
    // The operator must be the modulo operator (%)
    formatExpr.getOp() instanceof Mod and
    // The left operand must be a valid format string with named specifiers
    format_string(formatExpr.getLeft()) and
    mapping_format(formatExpr.getLeft()) and
    // Extract the right operand which should be the data source for formatting
    dataObject = formatExpr.getRight() and
    // Get the class of the right operand to check its type
    dataObject.pointsTo().getClass() = objectClass and
    // The right operand's class must not be a mapping type
    not objectClass.isMapping()
  )
select dataObject, "Right hand side of a % operator must be a mapping, not class $@.", objectClass, objectClass.getName()