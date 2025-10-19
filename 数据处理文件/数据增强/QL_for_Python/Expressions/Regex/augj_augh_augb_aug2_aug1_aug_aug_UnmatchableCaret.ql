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
 * Identifies regular expression patterns containing caret symbols (^) that are positioned incorrectly.
 * A caret is considered misplaced when:
 * - It appears as a literal character at the given position
 * - It's not located at the start of the pattern (where it functions as a valid start anchor)
 * - The regular expression is not in MULTILINE or VERBOSE mode (which allow mid-string anchors)
 */
predicate contains_invalid_caret(RegExp regexPattern, int caretPosition) {
  // Check for the presence of a caret character at the specified location
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  
  // Verify the caret is not at the pattern's beginning (where it would be valid as a start anchor)
  not regexPattern.firstItem(caretPosition, caretPosition + 1) and
  
  // Ensure the regex mode doesn't permit mid-string anchor usage
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE"
}

// Main query to locate regular expressions with unmatchable caret symbols
from RegExp faultyRegex, int caretPosition
where contains_invalid_caret(faultyRegex, caretPosition)
select faultyRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."