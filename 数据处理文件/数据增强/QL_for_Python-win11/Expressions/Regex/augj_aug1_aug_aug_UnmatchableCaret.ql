/**
 * @name Unmatchable caret in regular expression
 * @description Regular expressions containing a caret '^' in the middle cannot be matched, whatever the input.
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

/**
 * Identifies regex patterns with invalid mid-string caret positions:
 * - Pattern lacks MULTILINE/VERBOSE modes (which permit mid-string anchors)
 * - Literal '^' exists at specified position
 * - Caret isn't at pattern start (where it functions as valid anchor)
 */
predicate containsInvalidCaret(RegExp pattern, int caretPos) {
  // Verify caret isn't at pattern start
  not pattern.firstItem(caretPos, caretPos + 1) and
  
  // Confirm pattern doesn't allow mid-string anchors
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE") and
  
  // Verify literal caret presence at position
  pattern.specialCharacter(caretPos, caretPos + 1, "^")
}

// Locate regex patterns with problematic mid-string carets
from RegExp regexWithIssue, int caretOffset
where containsInvalidCaret(regexWithIssue, caretOffset)
select regexWithIssue,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."