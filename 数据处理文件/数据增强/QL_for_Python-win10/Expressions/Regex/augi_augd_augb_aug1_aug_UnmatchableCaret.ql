/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions containing a caret '^' symbol 
 *              outside the starting position. Such patterns become unmatchable 
 *              in standard regex modes since '^' only anchors to string beginnings 
 *              (unless MULTILINE mode is enabled).
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

// Define pattern and caret position variables
from RegExp regexPattern, int caretPosition

// Validate unmatchable caret conditions through two logical blocks:
// Block 1: Verify caret existence and invalid positioning
where 
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  not regexPattern.firstItem(caretPosition, caretPosition + 1) and
  
  // Block 2: Confirm incompatible regex modes
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE"

// Output detection results with diagnostic details
select regexPattern,
  "Unmatchable caret detected at offset " + caretPosition.toString() + " in this regular expression."