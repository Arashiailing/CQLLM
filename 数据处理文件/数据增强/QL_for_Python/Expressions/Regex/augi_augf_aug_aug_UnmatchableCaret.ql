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
 * Identifies regular expression patterns that contain a caret ('^') which cannot be matched
 * at the specified position. A caret is unmatchable when it appears in the middle of a pattern
 * and the pattern is not in MULTILINE or VERBOSE mode (these modes would allow the caret
 * to match at the beginning of each line).
 */
predicate has_unmatchable_caret(RegExp regexExpr, int caretLoc) {
  // Check that the regex mode doesn't permit mid-pattern caret matching
  not regexExpr.getAMode() = "MULTILINE" and
  not regexExpr.getAMode() = "VERBOSE" and
  // Verify the presence of a caret character at the specified location
  regexExpr.specialCharacter(caretLoc, caretLoc + 1, "^") and
  // Ensure the caret is not at the beginning of the pattern
  not regexExpr.firstItem(caretLoc, caretLoc + 1)
}

// Find all regular expressions that contain unmatchable carets
from RegExp invalidRegex, int caretPos
where has_unmatchable_caret(invalidRegex, caretPos)
select invalidRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPos.toString() + "."