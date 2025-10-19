/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions containing a caret ('^') symbol 
 *              in non-starting positions, which renders them ineffective 
 *              under standard regex matching modes.
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

// Define variables for the regex pattern and caret position
from RegExp pattern, int caretPosition

// Validate regex mode constraints
where 
  // Exclude MULTILINE mode where caret matches line starts
  not pattern.getAMode() = "MULTILINE" and
  // Exclude VERBOSE mode which may alter pattern interpretation
  not pattern.getAMode() = "VERBOSE" and
  // Confirm presence of caret symbol at specified position
  pattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  // Verify caret is not at pattern start position
  not pattern.firstItem(caretPosition, caretPosition + 1)

// Generate diagnostic message with position details
select pattern,
  "Unmatchable caret found at position " + caretPosition.toString() + 
  " in this regular expression pattern."