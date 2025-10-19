/**
 * @name Backspace escape in regular expression
 * @description Regular expressions using '\b' to denote a backspace character may cause 
 *              confusion since it's typically interpreted as a word boundary anchor.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp pattern, int escapeLocation
where
  // Locate a backslash character that serves as an escape at the specified position
  pattern.escapingChar(escapeLocation) and
  // Verify that the character immediately after the backslash is 'b'
  pattern.getChar(escapeLocation + 1) = "b" and
  // Confirm that this escape sequence is positioned within a character set
  exists(int setBeginning, int setTermination | 
    // Identify a character set encompassing the escape sequence
    pattern.charSet(setBeginning, setTermination) and
    // Ensure the escape location falls within the character set boundaries
    setBeginning < escapeLocation and 
    setTermination > escapeLocation
  )
select pattern, "Backspace escape in regular expression at offset " + escapeLocation + "."