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
 * Detects regex patterns with misplaced caret symbols:
 * - The pattern is not in MULTILINE or VERBOSE mode (these modes allow mid-string anchors)
 * - Contains a literal '^' character at the specified position
 * - The caret is not at the beginning of the pattern (where it serves as a valid start anchor)
 */
predicate contains_invalid_caret(RegExp pattern, int caretLocation) {
  // Ensure the regex doesn't use modes that allow mid-string anchors
  not pattern.getAMode() = "MULTILINE" and
  not pattern.getAMode() = "VERBOSE" and
  
  // Check for caret existence at the specified position
  pattern.specialCharacter(caretLocation, caretLocation + 1, "^") and
  
  // Exclude valid start-of-pattern anchors
  not pattern.firstItem(caretLocation, caretLocation + 1)
}

// Find regex patterns with invalid mid-string caret symbols
from RegExp invalidRegex, int caretPosition
where contains_invalid_caret(invalidRegex, caretPosition)
select invalidRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."