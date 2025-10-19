/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions containing a caret '^' in non-starting positions,
 *              which prevents them from matching any input string under standard modes.
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

// Identify regex patterns and caret positions
from RegExp re, int caretPos
// Validate unmatchable caret conditions:
// 1. Regex operates without MULTILINE mode
// 2. Regex operates without VERBOSE mode
// 3. Caret character exists at specified position
// 4. Caret is not positioned at regex start
where not re.getAMode() = "MULTILINE" and
      not re.getAMode() = "VERBOSE" and
      re.specialCharacter(caretPos, caretPos + 1, "^") and
      not re.firstItem(caretPos, caretPos + 1)
// Output regex with diagnostic message
select re,
  "Unmatchable caret detected at offset " + caretPos.toString() + " in this regular expression."