/**
 * @name Unmatchable dollar in regular expression
 * @description Detects regular expressions with a misplaced '$' character that can never match any input string.
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

/**
 * Identifies regular expressions containing a dollar sign '$' that cannot be matched
 * due to its position not being at the end of the pattern.
 * 
 * This predicate checks three conditions:
 * 1. The regex doesn't use MULTILINE or VERBOSE modes (where '$' has special meaning)
 * 2. There's a '$' character at the specified offset
 * 3. The '$' is not at the end of the regex pattern
 */
predicate contains_invalid_dollar_position(RegExp regex, int offset) {
  // Ensure the regex pattern is not in MULTILINE or VERBOSE mode
  not (regex.getAMode() = "MULTILINE" or regex.getAMode() = "VERBOSE") and
  // Verify the presence of a dollar character at the given offset
  regex.specialCharacter(offset, offset + 1, "$") and
  // Confirm the dollar sign is not positioned at the end of the pattern
  not regex.lastItem(offset, offset + 1)
}

// Main query to find regular expressions with unmatchable dollar signs
from RegExp regex, int location
where contains_invalid_dollar_position(regex, location)
select regex,
  "This regular expression includes an unmatchable dollar at offset " + location.toString() + "."