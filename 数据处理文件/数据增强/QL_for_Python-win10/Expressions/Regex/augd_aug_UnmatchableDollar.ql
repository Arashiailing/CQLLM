/**
 * @name Unmatchable dollar in regular expression
 * @description Regular expressions containing a dollar '$' in the middle cannot be matched, whatever the input.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/regex/unmatchable-dollar
 */

import python
import semmle.python.regex

// Predicate identifying regex patterns with misplaced dollar signs
predicate hasUnmatchableDollar(RegExp pattern, int pos) {
  // Confirm regex excludes MULTILINE and VERBOSE modes
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE") and
  // Verify presence of '$' character at specified position
  pattern.specialCharacter(pos, pos + 1, "$") and
  // Ensure dollar sign isn't the final element in pattern
  not pattern.lastItem(pos, pos + 1)
}

// Query to locate regex patterns containing problematic dollar signs
from RegExp pattern, int pos
where hasUnmatchableDollar(pattern, pos)
select pattern,
  "This regular expression includes an unmatchable dollar at offset " + pos.toString() + "."