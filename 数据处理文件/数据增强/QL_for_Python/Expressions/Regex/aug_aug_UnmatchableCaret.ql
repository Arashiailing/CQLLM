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
 * Identifies if a regular expression pattern contains an unmatchable caret '^' at a specific location.
 * An unmatchable caret is defined as one that appears in the middle of a regex pattern
 * when the regex is not in MULTILINE or VERBOSE mode.
 */
predicate has_unmatchable_caret(RegExp regexExpr, int caretLoc) {
  // Check that the regex is not in modes that would allow '^' to match in the middle
  not regexExpr.getAMode() = "MULTILINE" and
  not regexExpr.getAMode() = "VERBOSE" and
  // Verify there is a caret character at the specified location
  regexExpr.specialCharacter(caretLoc, caretLoc + 1, "^") and
  // Ensure the caret is not at the beginning of the pattern
  not regexExpr.firstItem(caretLoc, caretLoc + 1)
}

// Find all regular expressions that contain unmatchable carets
from RegExp targetRegex, int caretPos
where has_unmatchable_caret(targetRegex, caretPos)
select targetRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPos.toString() + "."