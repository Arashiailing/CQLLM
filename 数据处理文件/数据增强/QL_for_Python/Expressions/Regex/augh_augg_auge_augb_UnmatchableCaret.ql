/**
 * @name Misplaced caret in regular expression
 * @description Identifies regular expressions that contain a caret '^' symbol in positions other than the start, rendering them ineffective without MULTILINE/VERBOSE flags.
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

// Locate regex patterns containing incorrectly positioned caret symbols
// which fail to match any input in the absence of MULTILINE/VERBOSE modes
from RegExp regexExpr, int caretLoc
where 
  // Check that neither MULTILINE nor VERBOSE modes are enabled
  not exists(string mode | mode = "MULTILINE" or mode = "VERBOSE" | regexExpr.getAMode() = mode) and
  // Verify caret exists and is not at the beginning
  regexExpr.specialCharacter(caretLoc, caretLoc + 1, "^") and
  not regexExpr.firstItem(caretLoc, caretLoc + 1)
select regexExpr,
  "This regular expression includes an unmatchable caret at offset " + caretLoc.toString() + "."