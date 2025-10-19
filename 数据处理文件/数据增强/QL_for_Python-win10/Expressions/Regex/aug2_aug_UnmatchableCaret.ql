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

// Identify regex patterns and caret positions
from RegExp regex, int caretPosition
// Validate unmatchable caret conditions:
// 1. Caret character exists at specified position
// 2. Caret is not at the start of the pattern
// 3. MULTILINE mode is disabled
// 4. VERBOSE mode is disabled
where regex.specialCharacter(caretPosition, caretPosition + 1, "^") and
      not regex.firstItem(caretPosition, caretPosition + 1) and
      not regex.getAMode() = "MULTILINE" and
      not regex.getAMode() = "VERBOSE"
// Output regex with diagnostic message
select regex,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."