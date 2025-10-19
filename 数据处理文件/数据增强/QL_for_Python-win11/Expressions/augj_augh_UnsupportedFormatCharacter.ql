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

// Import core Python analysis capabilities
import python
// Import specialized string processing utilities
import semmle.python.strings

// Identify expressions with invalid format specifiers
from Expr problematicFormatExpr, int errorIndex
where 
    // Locate the position of illegal conversion specifier
    exists(int illegalSpecifierPosition | 
        illegalSpecifierPosition = illegal_conversion_specifier(problematicFormatExpr) and 
        errorIndex = illegalSpecifierPosition
    )
// Generate detailed error report with location information
select problematicFormatExpr, "Invalid conversion specifier at index " + errorIndex + " of " + repr(problematicFormatExpr) + "."