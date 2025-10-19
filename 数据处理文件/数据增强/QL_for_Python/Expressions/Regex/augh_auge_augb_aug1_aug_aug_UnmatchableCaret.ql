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
 * Identifies regex patterns with misplaced caret symbols:
 * - Pattern must not use MULTILINE/VERBOSE modes (these allow mid-string anchors)
 * - Must contain literal '^' at specified position
 * - Caret cannot be at pattern start (valid start anchor position)
 */
predicate contains_invalid_caret(RegExp regexPattern, int caretPos) {
  // Exclude modes permitting mid-string anchors
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE" and
  
  // Verify literal caret exists at position
  regexPattern.specialCharacter(caretPos, caretPos + 1, "^") and
  
  // Ensure caret isn't at valid start position
  not regexPattern.firstItem(caretPos, caretPos + 1)
}

// Locate regex patterns containing invalid mid-string carets
from RegExp invalidRegex, int caretPosition
where contains_invalid_caret(invalidRegex, caretPosition)
select invalidRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."