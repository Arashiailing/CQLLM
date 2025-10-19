/**
 * @name Unmatchable caret in regular expression
 * @description Finds regular expressions that have a caret '^' symbol positioned in the middle, making them impossible to match.
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
 * Detects regular expression patterns containing misplaced caret symbols.
 * The caret is deemed misplaced if:
 * - The regex pattern doesn't use MULTILINE or VERBOSE flags (these flags enable mid-string anchors)
 * - There's a literal '^' character at the given position
 * - The caret is not located at the pattern's start (where it serves as a valid start-of-string anchor)
 */
predicate contains_invalid_caret(RegExp pattern, int caretPosition) {
  // Check that the regex doesn't employ flags permitting mid-string anchors
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE") and
  
  // Confirm existence of a caret character precisely at the specified location
  // and rule out valid scenarios where the caret appears at pattern's beginning
  pattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  not pattern.firstItem(caretPosition, caretPosition + 1)
}

// Primary query that identifies all regular expressions containing unmatchable caret symbols
from RegExp invalidPattern, int caretOffset
where contains_invalid_caret(invalidPattern, caretOffset)
select invalidPattern,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."