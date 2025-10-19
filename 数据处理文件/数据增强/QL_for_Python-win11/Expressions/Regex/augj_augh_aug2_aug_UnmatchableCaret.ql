/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions containing a caret '^' symbol 
 *              in non-starting positions, which prevents them from matching
 *              any input string under standard matching modes.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/regex/unmatchable-caret
 */

import python
import semmle.python.regex

from RegExp rePattern, int caretPosition
where
  // Locate caret character at specific position
  rePattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  // Verify caret is not at pattern start position
  not rePattern.firstItem(caretPosition, caretPosition + 1) and
  // Ensure neither MULTILINE nor VERBOSE mode is enabled
  not (rePattern.getAMode() = "MULTILINE" or rePattern.getAMode() = "VERBOSE")
select rePattern,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."