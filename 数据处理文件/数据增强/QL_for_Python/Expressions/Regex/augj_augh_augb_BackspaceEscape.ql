/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used as a backspace character within regular expressions.
 *              This pattern can cause confusion since '\b' typically functions as a word boundary assertion.
 *              The query specifically targets '\b' sequences found inside character sets (square brackets),
 *              where it is interpreted as a backspace character rather than a word boundary marker.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int escapePosition
where
  // Verify there's an escape character (backslash) at the specified position
  regex.escapingChar(escapePosition) and
  // Confirm the character immediately following the backslash is 'b', creating the '\b' sequence
  regex.getChar(escapePosition + 1) = "b" and
  // Validate that the '\b' sequence occurs within a character set context (inside square brackets []),
  // where it functions as a backspace character rather than a word boundary
  exists(int charSetStart, int charSetEnd | 
    regex.charSet(charSetStart, charSetEnd) and
    charSetStart < escapePosition and 
    charSetEnd > escapePosition
  )
select regex, "Backspace escape in regular expression at offset " + escapePosition + "."