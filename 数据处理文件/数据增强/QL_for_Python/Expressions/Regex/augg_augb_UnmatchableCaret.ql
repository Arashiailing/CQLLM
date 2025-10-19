/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions containing a caret '^' in the middle,
 *              which cannot match any input string unless MULTILINE mode is enabled.
 *              In MULTILINE mode, '^' matches the start of each line, not just the start of the string.
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

// Identify regular expressions with unmatchable caret characters
from RegExp pattern, int caretOffset
where 
  // Check if the pattern contains a caret character at the specified position
  pattern.specialCharacter(caretOffset, caretOffset + 1, "^") and
  // Ensure the caret is not at the start of the pattern
  not pattern.firstItem(caretOffset, caretOffset + 1) and
  // Exclude patterns that enable MULTILINE mode (where ^ matches line start)
  not pattern.getAMode() = "MULTILINE" and
  // Exclude patterns that enable VERBOSE mode (where whitespace is ignored)
  not pattern.getAMode() = "VERBOSE"
select pattern,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."