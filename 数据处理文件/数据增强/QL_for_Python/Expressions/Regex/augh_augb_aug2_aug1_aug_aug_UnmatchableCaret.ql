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
 * Detects regular expression patterns with improperly positioned caret characters.
 * This predicate identifies carets that are invalid because:
 * - The regex is not in MULTILINE or VERBOSE mode (these modes permit mid-string anchors)
 * - A literal '^' is found at the given position
 * - The caret is not located at the pattern's start (where it serves as a valid start anchor)
 */
predicate has_misplaced_caret(RegExp regexExpr, int caretLoc) {
  // Verify the presence of a caret character at the specified position
  regexExpr.specialCharacter(caretLoc, caretLoc + 1, "^") and
  
  // Ensure the caret is not at the beginning of the pattern (where it would be valid)
  not regexExpr.firstItem(caretLoc, caretLoc + 1) and
  
  // Confirm the regex mode doesn't allow mid-string anchors
  not regexExpr.getAMode() = "MULTILINE" and
  not regexExpr.getAMode() = "VERBOSE"
}

// Primary query to identify regular expressions with unmatchable caret symbols
from RegExp problematicRegex, int caretLoc
where has_misplaced_caret(problematicRegex, caretLoc)
select problematicRegex,
  "This regular expression includes an unmatchable caret at offset " + caretLoc.toString() + "."