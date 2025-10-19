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

// This query detects regular expression patterns containing a caret '^' character
// that appears in a non-starting position, making the pattern unmatchable.
// We exclude patterns using MULTILINE mode (where ^ matches line starts) and
// VERBOSE mode (where whitespace formatting is ignored).
from RegExp regexPattern, int caretPosition
where 
  // Exclude regex patterns enabling MULTILINE mode (where ^ matches line start)
  not regexPattern.getAMode() = "MULTILINE" and
  // Exclude regex patterns enabling VERBOSE mode (where whitespace is ignored)
  not regexPattern.getAMode() = "VERBOSE" and
  // Confirm caret character exists at the specified position
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  // Ensure caret is not positioned at the start of the regex pattern
  not regexPattern.firstItem(caretPosition, caretPosition + 1)
select regexPattern,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."