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

// Identify regex patterns with misplaced caret characters that cannot match
// any input when MULTILINE/VERBOSE modes are disabled
from RegExp re, int caretOffset
where 
  // Exclude patterns with MULTILINE mode (where ^ matches line start)
  not re.getAMode() = "MULTILINE" and
  // Exclude patterns with VERBOSE mode (where whitespace is ignored)
  not re.getAMode() = "VERBOSE" and
  // Verify caret exists at specified position
  re.specialCharacter(caretOffset, caretOffset + 1, "^") and
  // Ensure caret is not at pattern start position
  not re.firstItem(caretOffset, caretOffset + 1)
select re,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."