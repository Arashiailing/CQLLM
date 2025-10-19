/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions with a caret '^' placed in non-starting positions,
 *              making them unable to match any input under standard regex modes.
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

// Define variables for the regular expression and caret location
from RegExp rePattern, int caretLoc

// Check if the regex is in standard mode (not MULTILINE or VERBOSE)
where not rePattern.getAMode() = "MULTILINE" and
      not rePattern.getAMode() = "VERBOSE" and
      // Verify the presence of a caret character at the specified location
      rePattern.specialCharacter(caretLoc, caretLoc + 1, "^") and
      // Ensure the caret is not at the beginning of the regex pattern
      not rePattern.firstItem(caretLoc, caretLoc + 1)

// Report the regex pattern with a detailed diagnostic message
select rePattern,
  "Unmatchable caret found at position " + caretLoc.toString() + " in this regular expression pattern."