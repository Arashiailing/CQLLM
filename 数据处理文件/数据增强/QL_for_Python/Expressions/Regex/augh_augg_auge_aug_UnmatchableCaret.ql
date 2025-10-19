/**
 * @name Invalid caret placement in regex pattern
 * @description Detects regular expressions with a caret symbol '^' 
 *              in non-starting positions, rendering the pattern unmatchable.
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

// Define regex pattern and caret position variables
from RegExp regex, int caretPos
// Validate problematic caret placement conditions
where 
  // Exclude multi-line mode where caret has line-start semantics
  not regex.getAMode() = "MULTILINE" and
  // Exclude verbose mode where whitespace/comments alter parsing
  not regex.getAMode() = "VERBOSE" and
  // Identify caret symbol occurrence at specific position
  regex.specialCharacter(caretPos, caretPos + 1, "^") and
  // Verify caret is not at pattern start position
  not regex.firstItem(caretPos, caretPos + 1)
// Output regex pattern with diagnostic message
select regex,
  "Unmatchable caret found at offset " + caretPos.toString() + " in this regular expression."