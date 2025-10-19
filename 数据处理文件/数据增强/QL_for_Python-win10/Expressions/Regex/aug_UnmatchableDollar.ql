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

// Enhanced predicate to detect unmatchable dollar signs
predicate unmatchable_dollar(RegExp regex, int position) {
  // Verify regex mode excludes MULTILINE and VERBOSE
  not (regex.getAMode() = "MULTILINE" or regex.getAMode() = "VERBOSE") and
  // Check for '$' character at specified position
  regex.specialCharacter(position, position + 1, "$") and
  // Ensure '$' is not the last element in the pattern
  not regex.lastItem(position, position + 1)
}

// Query for regex patterns with problematic dollar signs
from RegExp regex, int offset
where unmatchable_dollar(regex, offset)
select regex,
  "This regular expression includes an unmatchable dollar at offset " + offset.toString() + "."