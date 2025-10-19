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

// Identify regular expressions with unmatchable caret characters
from RegExp regex, int caretPosition
where 
  // Exclude regex patterns that enable MULTILINE mode (where ^ matches line start)
  not regex.getAMode() = "MULTILINE" and
  // Exclude regex patterns that enable VERBOSE mode (where whitespace is ignored)
  not regex.getAMode() = "VERBOSE" and
  // Verify caret character exists at the specified position
  regex.specialCharacter(caretPosition, caretPosition + 1, "^") and
  // Ensure caret is not at the start of the regex pattern
  not regex.firstItem(caretPosition, caretPosition + 1)
select regex,
  "This regular expression includes an unmatchable caret at offset " + caretPosition.toString() + "."