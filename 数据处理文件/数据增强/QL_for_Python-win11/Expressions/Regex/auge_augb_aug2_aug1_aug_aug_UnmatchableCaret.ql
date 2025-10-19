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
 * Detects regular expression patterns with improperly positioned caret symbols.
 * A caret is considered invalid when:
 * 1. The regex is not in MULTILINE or VERBOSE mode (modes permitting mid-string anchors)
 * 2. A literal '^' character exists at the specified position
 * 3. The caret does not appear at the pattern start (where it serves as a valid start anchor)
 */
predicate hasInvalidCaretPosition(RegExp regex, int caretLoc) {
  // Verify regex mode doesn't permit mid-string anchors
  not regex.getAMode() = "MULTILINE" and
  not regex.getAMode() = "VERBOSE" and
  
  // Confirm caret character presence at specified location
  regex.specialCharacter(caretLoc, caretLoc + 1, "^") and
  
  // Exclude valid start-of-pattern caret anchors
  not regex.firstItem(caretLoc, caretLoc + 1)
}

// Query to identify regular expressions containing unmatchable caret symbols
from RegExp problematicRegex, int caretLoc
where hasInvalidCaretPosition(problematicRegex, caretLoc)
select problematicRegex,
  "This regular expression includes an unmatchable caret at offset " + caretLoc.toString() + "."