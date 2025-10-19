/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions with a caret '^' symbol in the middle that can never match any input string.
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

// Locate regular expressions containing problematic caret characters
from RegExp pattern, int caretLoc
where 
  // Exclude patterns with MULTILINE flag (where ^ matches start of lines)
  not pattern.getAMode() = "MULTILINE" and
  // Exclude patterns with VERBOSE flag (where whitespace is insignificant)
  not pattern.getAMode() = "VERBOSE" and
  // Verify the caret character exists at the specified position
  pattern.specialCharacter(caretLoc, caretLoc + 1, "^") and
  // Confirm the caret is not positioned at the pattern's beginning
  not pattern.firstItem(caretLoc, caretLoc + 1)
select pattern,
  "This regular expression includes an unmatchable caret at offset " + caretLoc.toString() + "."