/**
 * @name Unsupported format character
 * @description Detects unsupported format characters in Python format strings.
 *              This query identifies expressions containing invalid conversion specifiers
 *              that may cause runtime errors or unexpected behavior.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis module
import python
// Import string processing utilities for format string analysis
import semmle.python.strings

// Define query to detect expressions with invalid format specifiers
from Expr problematicFormatExpr, int specifierErrorPosition
// Identify the position of illegal conversion specifiers within the expression
where specifierErrorPosition = illegal_conversion_specifier(problematicFormatExpr)
// Output the problematic expression along with detailed error information
select problematicFormatExpr, "Invalid conversion specifier at index " + specifierErrorPosition + " of " + repr(problematicFormatExpr) + "."