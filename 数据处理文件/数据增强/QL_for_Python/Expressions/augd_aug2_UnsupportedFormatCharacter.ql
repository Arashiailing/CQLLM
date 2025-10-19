/**
 * @name Unsupported format character
 * @description Identifies expressions containing invalid percent-style format specifiers that may cause runtime errors
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import Python analysis framework
import python
// Import string processing utilities
import semmle.python.strings

// Identify expressions with illegal format specifiers
from Expr formatExpr, int illegalSpecifierIndex
// Match expressions where illegal conversion specifiers exist
where illegal_conversion_specifier(formatExpr) = illegalSpecifierIndex
// Report problematic expressions with diagnostic details
select formatExpr, "Invalid conversion specifier at index " + illegalSpecifierIndex + " of " + repr(formatExpr) + "."