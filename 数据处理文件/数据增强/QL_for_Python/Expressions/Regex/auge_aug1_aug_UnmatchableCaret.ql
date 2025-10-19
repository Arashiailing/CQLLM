/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions containing a caret '^' in non-starting positions,
 *              which renders them incapable of matching any input string under standard modes.
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

// Define the regular expression pattern and caret position
from RegExp regexPattern, int caretPosition

// Validate conditions for unmatchable caret:
// - Regex operates without MULTILINE mode
// - Regex operates without VERBOSE mode
// - Caret character exists at the specified position
// - Caret is not positioned at the regex start
where not regexPattern.getAMode() = "MULTILINE" and
      not regexPattern.getAMode() = "VERBOSE" and
      regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
      not regexPattern.firstItem(caretPosition, caretPosition + 1)

// Output the regex pattern with a diagnostic message
select regexPattern,
  "Unmatchable caret detected at offset " + caretPosition.toString() + " in this regular expression."