/**
 * @name Invalid format specifier
 * @description Identifies format strings that use unsupported or invalid conversion specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import fundamental Python analysis features
import python
// Import string manipulation utilities for validating format strings
import semmle.python.strings

// This query detects Python format string expressions that contain invalid conversion specifiers.
// It pinpoints the exact location of the invalid specifier within the string.
from Expr formatExpression, int badSpecifierPosition
where 
    // Locate invalid conversion specifiers in format strings
    // Returns the index position of the first invalid specifier encountered
    badSpecifierPosition = illegal_conversion_specifier(formatExpression)
select 
    // Report the problematic expression with detailed error context
    formatExpression, 
    "Invalid conversion specifier at index " + badSpecifierPosition + " of " + repr(formatExpression) + "."