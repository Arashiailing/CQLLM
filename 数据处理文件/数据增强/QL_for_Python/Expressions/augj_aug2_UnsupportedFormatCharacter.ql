/**
 * @name Invalid percent-style format specifier
 * @description Identifies format strings with unsupported conversion specifiers in percent-style formatting
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

// Locate expressions containing invalid percent-style format specifiers
from Expr formatString, int invalidSpecifierIndex
where invalidSpecifierIndex = illegal_conversion_specifier(formatString)
// Generate a report for each identified issue
select formatString, "Invalid conversion specifier at index " + invalidSpecifierIndex + " of " + repr(formatString) + "."