/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions containing a caret '^' symbol in non-starting positions.
 *              Such patterns become unmatchable in standard regex modes since '^' only anchors
 *              to string beginnings (unless MULTILINE mode is enabled).
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

// Define pattern and caret location variables
from RegExp regexExpr, int caretOffset

// Validate unmatchable caret conditions through:
// - Caret character presence at specified location
// - Caret not positioned at pattern start
// - Absence of MULTILINE mode (enables line-start matching)
// - Absence of VERBOSE mode (alters pattern interpretation)
where 
  // Verify caret existence and invalid position
  regexExpr.specialCharacter(caretOffset, caretOffset + 1, "^") and
  not regexExpr.firstItem(caretOffset, caretOffset + 1) and
  
  // Confirm incompatible regex modes
  not regexExpr.getAMode() = "MULTILINE" and
  not regexExpr.getAMode() = "VERBOSE"

// Output detection results with diagnostic details
select regexExpr,
  "Unmatchable caret detected at offset " + caretOffset.toString() + " in this regular expression."