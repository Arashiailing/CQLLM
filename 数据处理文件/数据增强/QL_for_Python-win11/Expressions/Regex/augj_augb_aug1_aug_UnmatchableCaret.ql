/**
 * @name Unmatchable caret in regular expression
 * @description Detects regular expressions containing a caret '^' symbol in non-starting positions.
 *              Such patterns become unmatchable under standard regex modes since '^' only matches
 *              line beginnings in MULTILINE mode, which is excluded by the query conditions.
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

// Define analysis variables: regex pattern and caret location
from RegExp regex, int caretPos

// Verify problematic regex conditions:
// 1. Exclude MULTILINE mode (where '^' matches line starts)
// 2. Exclude VERBOSE mode (which alters pattern interpretation)
// 3. Confirm caret presence at specified position
// 4. Ensure caret isn't at pattern start
where 
  not regex.getAMode() = "MULTILINE" and
  not regex.getAMode() = "VERBOSE" and
  regex.specialCharacter(caretPos, caretPos + 1, "^") and
  not regex.firstItem(caretPos, caretPos + 1)

// Generate diagnostic output with location details
select regex,
  "Unmatchable caret detected at offset " + caretPos.toString() + " in this regular expression."