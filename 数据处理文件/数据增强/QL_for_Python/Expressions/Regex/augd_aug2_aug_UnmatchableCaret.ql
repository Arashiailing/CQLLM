/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions with a caret '^' in non-starting positions,
 *              making them unable to match any input string.
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
from RegExp pattern, int caretOffset
// Validate unmatchable caret conditions:
// 1. Caret character exists at specified position
// 2. Caret is not at the start of the pattern
// 3. MULTILINE mode is disabled
// 4. VERBOSE mode is disabled
where 
  // Check if the pattern contains a caret at the specified position
  pattern.specialCharacter(caretOffset, caretOffset + 1, "^") and
  // Ensure the caret is not at the start of the pattern
  not pattern.firstItem(caretOffset, caretOffset + 1) and
  // Verify that MULTILINE mode is not enabled (which would allow ^ to match line starts)
  not pattern.getAMode() = "MULTILINE" and
  // Confirm that VERBOSE mode is not enabled (which might ignore special characters)
  not pattern.getAMode() = "VERBOSE"
// Output regex with diagnostic message
select pattern,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."