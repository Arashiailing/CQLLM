/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions containing a caret '^' in non-starting positions,
 *              which renders them incapable of matching any input string.
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

from RegExp regexPattern, int caretOffset
where
  // Verify caret character exists at specified position
  regexPattern.specialCharacter(caretOffset, caretOffset + 1, "^") and
  // Confirm caret is not at pattern start
  not regexPattern.firstItem(caretOffset, caretOffset + 1) and
  // Ensure MULTILINE mode is disabled
  not regexPattern.getAMode() = "MULTILINE" and
  // Ensure VERBOSE mode is disabled
  not regexPattern.getAMode() = "VERBOSE"
select regexPattern,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."