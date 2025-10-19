/**
 * @name Unsupported format character
 * @description Detects unsupported format characters in Python percent-format strings
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character */

// Import Python analysis libraries for code parsing and processing
import python
// Import string manipulation utilities for format string analysis
import semmle.python.strings

// Identify format expressions with invalid conversion specifiers
from Expr formatExpr, int errorPos
// Calculate the position of illegal conversion specifier in the format expression
where exists(int specifierPosition | 
    specifierPosition = illegal_conversion_specifier(formatExpr) and 
    errorPos = specifierPosition
)
// Report the problematic expression with detailed error information
select formatExpr, "Invalid conversion specifier at index " + errorPos + " of " + repr(formatExpr) + "."