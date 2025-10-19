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
 * Detects invalidly positioned caret characters in regex patterns.
 * 
 * Invalid caret conditions:
 * - Pattern lacks MULTILINE/VERBOSE modes (which permit mid-string anchors)
 * - Literal '^' exists at the specified position
 * - Caret is not at pattern start (where it functions as valid start anchor)
 * 
 * @param pattern The analyzed regular expression pattern
 * @param position Location of the caret within the pattern
 */
predicate invalidCaretPosition(RegExp pattern, int position) {
  // Confirm literal caret exists at specified position
  pattern.specialCharacter(position, position + 1, "^") and
  
  // Verify caret is not at pattern start (where it's valid)
  not pattern.firstItem(position, position + 1) and
  
  // Ensure pattern lacks modes permitting mid-string anchors
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE")
}

// Identify regex patterns with unmatchable caret symbols
from RegExp regex, int caretLocation
where invalidCaretPosition(regex, caretLocation)
select regex,
  "This regular expression contains an unmatchable caret at position " + caretLocation.toString() + "."