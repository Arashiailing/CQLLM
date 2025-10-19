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
 * Detects regular expression patterns with misplaced caret characters.
 * 
 * A caret is deemed misplaced when:
 * - The regex pattern is not in MULTILINE or VERBOSE mode (modes permitting mid-string anchors)
 * - A literal '^' character is found at the given position
 * - The caret is not positioned at the start of the pattern (where it serves as a valid start anchor)
 * 
 * @param pattern The regular expression pattern under examination
 * @param caretLocation The position within the pattern where the caret is situated
 */
predicate containsMisplacedCaret(RegExp pattern, int caretLocation) {
  // Check that the regex doesn't employ modes allowing mid-string anchors
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE") and
  
  // Verify the presence of a caret character at the specified position
  pattern.specialCharacter(caretLocation, caretLocation + 1, "^") and
  
  // Confirm the caret is not at the pattern's beginning (where it's valid as a start anchor)
  not pattern.firstItem(caretLocation, caretLocation + 1)
}

// Primary query to locate regular expressions with unmatchable caret symbols
from RegExp regexWithIssue, int caretPosition
where containsMisplacedCaret(regexWithIssue, caretPosition)
select regexWithIssue,
  "This regular expression contains an unmatchable caret at position " + caretPosition.toString() + "."