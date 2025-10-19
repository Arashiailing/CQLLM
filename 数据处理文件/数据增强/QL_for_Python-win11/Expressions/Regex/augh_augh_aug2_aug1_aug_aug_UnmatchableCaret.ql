/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions with a caret '^' symbol positioned in the middle, which makes them impossible to match.
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
 * Determines if a regular expression contains a misplaced caret symbol.
 * A caret is considered misplaced when:
 * - The regex pattern doesn't use MULTILINE or VERBOSE flags (which allow mid-string anchors)
 * - There's a literal '^' character at the specified position
 * - The caret is not at the beginning of the pattern (where it acts as a valid start-of-string anchor)
 */
predicate hasMisplacedCaret(RegExp regexPattern, int caretLocation) {
  // Ensure the regex doesn't use flags that permit mid-string anchors
  not (regexPattern.getAMode() = "MULTILINE" or regexPattern.getAMode() = "VERBOSE") and
  
  // Verify there's a caret character at the given location
  // and ensure it's not at the pattern's start (where it would be valid)
  regexPattern.specialCharacter(caretLocation, caretLocation + 1, "^") and
  not regexPattern.firstItem(caretLocation, caretLocation + 1)
}

// Main query to find all regular expressions with unmatchable caret symbols
from RegExp faultyRegex, int caretPos
where hasMisplacedCaret(faultyRegex, caretPos)
select faultyRegex,
  "This regular expression includes an unmatchable caret at offset " + caretPos.toString() + "."