/**
 * @name Ambiguous backspace escape in regex character set
 * @description Detects ambiguous use of '\b' inside regex character sets where it could
 *              be interpreted as either backspace or word boundary, potentially causing
 *              unexpected behavior in pattern matching.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int escPosition
where
  // Find an escape character at the specified position in the regex pattern
  regex.escapingChar(escPosition) and
  // Confirm that 'b' character immediately follows the escape, forming '\b' sequence
  regex.getChar(escPosition + 1) = "b" and
  // Validate that this '\b' sequence appears within a character set definition
  exists(int setBegin, int setFinish |
    // Check that the escape position falls within character set boundaries
    setBegin < escPosition and 
    setFinish > escPosition and
    // Verify these positions actually define a character set in the regex
    regex.charSet(setBegin, setFinish)
  )
select regex, "Ambiguous backspace escape in character set at offset " + escPosition + "."