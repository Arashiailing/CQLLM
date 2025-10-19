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
 * Identifies regular expression patterns with invalidly positioned caret characters.
 * A caret is considered invalid when:
 * - The regex is not in MULTILINE or VERBOSE mode (which would allow mid-string anchors)
 * - A literal '^' character exists at the specified position
 * - The caret is not at the beginning of the pattern (where it functions as a valid start anchor)
 */
predicate contains_invalid_caret(RegExp regexExpr, int caretLoc) {
  // Ensure the regex doesn't use modes that would allow mid-string anchors
  not regexExpr.getAMode() = "MULTILINE" and
  not regexExpr.getAMode() = "VERBOSE" and
  
  // Verify the presence of a caret character at the exact location
  regexExpr.specialCharacter(caretLoc, caretLoc + 1, "^") and
  
  // Exclude valid cases where the caret is at the pattern start
  not regexExpr.firstItem(caretLoc, caretLoc + 1)
}

// Main query to find all regular expressions with unmatchable caret symbols
from RegExp faultyRegex, int caretPos
where contains_invalid_caret(faultyRegex, caretPos)
select faultyRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPos.toString() + "."