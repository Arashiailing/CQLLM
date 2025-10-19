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
 * Identifies regular expression patterns containing invalidly positioned caret characters.
 * A caret is considered invalid when:
 * - The regex pattern is not in MULTILINE or VERBOSE mode (which would allow mid-string anchors)
 * - A literal '^' character exists at the specified position
 * - The caret is not at the beginning of the pattern (where it functions as a valid start anchor)
 */
predicate contains_invalid_caret(RegExp regexPattern, int caretPosition) {
  // Check if regex mode allows mid-string anchors
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE" and
  
  // Verify presence of caret character at specified position
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  
  // Exclude valid cases where caret is at pattern start
  not regexPattern.firstItem(caretPosition, caretPosition + 1)
}

// Main query to detect regular expressions with unmatchable caret symbols
from RegExp faultyRegex, int caretPosition
where contains_invalid_caret(faultyRegex, caretPosition)
select faultyRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."