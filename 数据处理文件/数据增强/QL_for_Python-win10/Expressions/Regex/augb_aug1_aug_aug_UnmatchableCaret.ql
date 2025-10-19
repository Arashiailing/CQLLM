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
 * - Pattern lacks MULTILINE/VERBOSE modes (which allow mid-string anchors)
 * - Contains literal '^' at specified position
 * - Caret isn't at pattern start (where it functions as valid anchor)
 */
predicate has_unmatchable_caret(RegExp regex, int caretPos) {
  // Verify regex doesn't use modes that permit mid-string anchors
  not regex.getAMode() = "MULTILINE" and
  not regex.getAMode() = "VERBOSE" and
  
  // Confirm caret exists at exact position
  regex.specialCharacter(caretPos, caretPos + 1, "^") and
  
  // Exclude valid start-of-pattern anchors
  not regex.firstItem(caretPos, caretPos + 1)
}

// Locate regex patterns containing invalid mid-string carets
from RegExp badRegex, int caretLoc
where has_unmatchable_caret(badRegex, caretLoc)
select badRegex,
  "This regular expression includes an unmatchable caret at offset " + caretLoc.toString() + "."