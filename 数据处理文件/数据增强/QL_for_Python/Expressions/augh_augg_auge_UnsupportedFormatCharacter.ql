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

// This query identifies Python format string expressions containing invalid conversion specifiers.
// It determines the exact position where the invalid specifier occurs within the string.
from Expr formatStringExpr, int invalidSpecifierIndex
where 
    // Validate the format string expression to locate any invalid conversion specifiers
    // The function returns the index position of the first invalid specifier found
    invalidSpecifierIndex = illegal_conversion_specifier(formatStringExpr)
select 
    // Output the problematic expression with detailed error information
    formatStringExpr, 
    "Invalid conversion specifier at index " + invalidSpecifierIndex + " of " + repr(formatStringExpr) + "."