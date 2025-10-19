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
from Expr faultyFormatExpr, int invalidSpecifierIndex
// Validation condition: Determine the location of invalid conversion specifiers
where invalidSpecifierIndex = illegal_conversion_specifier(faultyFormatExpr)
// Result output: Report the problematic expression with detailed error context
select faultyFormatExpr, "Invalid conversion specifier at index " + invalidSpecifierIndex + " of " + repr(faultyFormatExpr) + "."