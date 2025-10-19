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

// Predicate to identify regular expressions with unmatchable dollar signs
predicate hasUnmatchableDollarSign(RegExp pattern, int charPosition) {
  // Check for dollar sign that is not at the end of the pattern
  pattern.specialCharacter(charPosition, charPosition + 1, "$") and
  not pattern.lastItem(charPosition, charPosition + 1) and
  // Ensure the regex is not in MULTILINE or VERBOSE mode
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE")
}

// Query to find regex patterns containing problematic dollar signs
from RegExp pattern, int dollarOffset
where hasUnmatchableDollarSign(pattern, dollarOffset)
select pattern,
  "This regular expression includes an unmatchable dollar at offset " + dollarOffset.toString() + "."