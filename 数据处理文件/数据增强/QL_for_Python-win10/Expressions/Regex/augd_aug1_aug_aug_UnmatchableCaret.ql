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
 * Identifies regex patterns with an invalidly positioned caret (^) character.
 * The caret is considered invalid when:
 * - The regex does not have MULTILINE or VERBOSE modes enabled (which allow mid-string anchors)
 * - A literal '^' character exists at the specified position
 * - The caret is not positioned at the start of the pattern (where it's valid as an anchor)
 */
predicate has_unmatchable_caret(RegExp regexExpr, int caretLoc) {
  // Check that the regex doesn't have modes that would allow mid-string anchors
  not regexExpr.getAMode() = "MULTILINE" and
  not regexExpr.getAMode() = "VERBOSE" and
  
  // Verify the presence of a caret character at the specified position
  regexExpr.specialCharacter(caretLoc, caretLoc + 1, "^") and
  
  // Ensure the caret is not at the beginning of the pattern (where it's valid)
  not regexExpr.firstItem(caretLoc, caretLoc + 1)
}

// Locate all regex patterns containing invalidly positioned carets
from RegExp faultyRegex, int caretPos
where has_unmatchable_caret(faultyRegex, caretPos)
select faultyRegex,
  "This regular expression contains an unmatchable caret character at position " + caretPos.toString() + "."