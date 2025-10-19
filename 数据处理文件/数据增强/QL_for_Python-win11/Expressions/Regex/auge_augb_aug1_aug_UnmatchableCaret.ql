/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions containing a caret '^' symbol in non-starting positions,
 *              rendering them incapable of matching any input string under standard regex modes.
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

// Define source variables: regex pattern and caret offset
from RegExp problematicRegex, int caretOffset

// Validate unmatchable caret conditions through:
// - Mode constraints (excluding MULTILINE/VERBOSE where '^' has special behavior)
// - Position validation (caret must exist and not be at pattern start)
where 
  // Verify regex mode restrictions
  not problematicRegex.getAMode() = "MULTILINE" and
  not problematicRegex.getAMode() = "VERBOSE" and
  
  // Confirm caret presence and invalid positioning
  problematicRegex.specialCharacter(caretOffset, caretOffset + 1, "^") and
  not problematicRegex.firstItem(caretOffset, caretOffset + 1)

// Generate diagnostic output with problematic regex and caret location
select problematicRegex,
  "Unmatchable caret detected at offset " + caretOffset.toString() + " in this regular expression."