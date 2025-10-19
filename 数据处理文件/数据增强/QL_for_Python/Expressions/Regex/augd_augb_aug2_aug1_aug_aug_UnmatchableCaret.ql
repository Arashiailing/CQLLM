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
 * 
 * A caret is considered invalid when:
 * - The regex pattern is not in MULTILINE or VERBOSE mode (which would allow mid-string anchors)
 * - A literal '^' character exists at the specified position
 * - The caret is not at the beginning of the pattern (where it functions as a valid start anchor)
 * 
 * @param regexExpr The regular expression pattern being analyzed
 * @param caretOffset The position within the pattern where the caret is located
 */
predicate hasInvalidCaretPosition(RegExp regexExpr, int caretOffset) {
  // Verify that the regex does not use modes that allow mid-string anchors
  not (regexExpr.getAMode() = "MULTILINE" or regexExpr.getAMode() = "VERBOSE") and
  
  // Confirm that a caret character exists at the specified position
  regexExpr.specialCharacter(caretOffset, caretOffset + 1, "^") and
  
  // Ensure the caret is not at the beginning of the pattern (where it's valid as a start anchor)
  not regexExpr.firstItem(caretOffset, caretOffset + 1)
}

// Main query to identify regular expressions with unmatchable caret symbols
from RegExp problematicRegex, int caretOffset
where hasInvalidCaretPosition(problematicRegex, caretOffset)
select problematicRegex,
  "This regular expression contains an unmatchable caret at position " + caretOffset.toString() + "."