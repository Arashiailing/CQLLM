/**
 * @name Unmatchable caret in regular expression
 * @description A regular expression containing a mid-pattern caret ('^') without MULTILINE/VERBOSE modes cannot match any input string.
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
 * - Pattern lacks MULTILINE/VERBOSE modes (which allow mid-string anchors)
 * - Contains literal '^' at specified position
 * - Caret isn't at pattern start (where it functions as valid anchor)
 */
predicate containsUnmatchableCaret(RegExp regexPattern, int caretPosition) {
  // Verify regex doesn't use modes that permit mid-string anchors
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE" and
  
  // Confirm caret exists at exact position
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  
  // Exclude valid start-of-pattern anchors
  not regexPattern.firstItem(caretPosition, caretPosition + 1)
}

// Locate regex patterns containing invalid mid-string carets
from RegExp invalidRegex, int caretOffset
where containsUnmatchableCaret(invalidRegex, caretOffset)
select invalidRegex,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."