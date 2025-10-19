/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions that contain a caret '^' character
 *              in positions other than the beginning, making them unable to
 *              match any input string.
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

// Locate regex patterns and their caret character positions
from RegExp regex, int caretOffset
// Verify conditions for an unmatchable caret:
// - Caret character exists at specified position
// - Caret is not at the start of the pattern
// - MULTILINE and VERBOSE modes are disabled
where regex.specialCharacter(caretOffset, caretOffset + 1, "^") and
      not regex.firstItem(caretOffset, caretOffset + 1) and
      not (regex.getAMode() = "MULTILINE" or regex.getAMode() = "VERBOSE")
// Display the regex along with a diagnostic message
select regex,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."