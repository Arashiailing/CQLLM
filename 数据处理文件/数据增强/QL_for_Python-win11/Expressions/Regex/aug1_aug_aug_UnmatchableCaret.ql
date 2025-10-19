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
 * Detects invalid caret positions in regex patterns where:
 * 1. The regex lacks MULTILINE/VERBOSE modes that allow mid-string anchors
 * 2. A literal '^' exists at the specified position
 * 3. The caret isn't at the pattern start (where it's valid)
 */
predicate has_unmatchable_caret(RegExp regexPattern, int caretPosition) {
  // Validate regex mode restrictions
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE" and
  
  // Confirm caret presence at exact position
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  
  // Exclude valid start-of-pattern anchors
  not regexPattern.firstItem(caretPosition, caretPosition + 1)
}

// Identify regex patterns with invalid mid-string carets
from RegExp problematicRegex, int caretOffset
where has_unmatchable_caret(problematicRegex, caretOffset)
select problematicRegex,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."