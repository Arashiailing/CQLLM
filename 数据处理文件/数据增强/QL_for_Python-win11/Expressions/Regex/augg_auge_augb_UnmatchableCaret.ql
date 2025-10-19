/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions containing a caret '^' in non-starting positions, making them impossible to match without MULTILINE/VERBOSE modes.
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

// Identify regular expression patterns with misplaced caret characters
// that cannot match any input when not in MULTILINE/VERBOSE modes
from RegExp regexPattern, int caretPosition
where 
  // Exclude patterns with MULTILINE mode enabled (where ^ matches line start)
  not regexPattern.getAMode() = "MULTILINE" and
  // Exclude patterns with VERBOSE mode enabled (where whitespace is ignored)
  not regexPattern.getAMode() = "VERBOSE" and
  // Confirm caret character is present at the specified position
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  // Ensure caret is not at the beginning of the regex pattern
  not regexPattern.firstItem(caretPosition, caretPosition + 1)
select regexPattern,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."