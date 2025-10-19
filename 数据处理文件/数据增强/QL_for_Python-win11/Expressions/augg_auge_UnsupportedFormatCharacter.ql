/**
 * @name Unsupported format character
 * @description Detects format strings containing unsupported or invalid conversion specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis capabilities
import python
// Import string processing utilities for format string validation
import semmle.python.strings

// Query definition: Identify expressions with invalid format specifiers
from Expr problematicFormatExpr, int specifierErrorPosition
// Validation condition: Determine the location of invalid conversion specifiers
where specifierErrorPosition = illegal_conversion_specifier(problematicFormatExpr)
// Result output: Report the problematic expression with detailed error context
select problematicFormatExpr, "Invalid conversion specifier at index " + specifierErrorPosition + " of " + repr(problematicFormatExpr) + "."