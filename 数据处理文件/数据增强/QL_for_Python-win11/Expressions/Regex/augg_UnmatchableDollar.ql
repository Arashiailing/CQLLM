/**
 * @name Unmatchable dollar in regular expression
 * @description A regular expression that has a dollar sign '$' in a non-terminal position will never match any input string.
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

// This predicate identifies regular expressions that contain a dollar sign '$' which is not at the end and thus cannot match.
predicate unmatchable_dollar(RegExp regex, int position) {
  // Check that neither MULTILINE nor VERBOSE mode is enabled
  not (regex.getAMode() = "MULTILINE" or regex.getAMode() = "VERBOSE") and
  // Verify presence of '$' character at specified position
  regex.specialCharacter(position, position + 1, "$") and
  // Confirm the dollar sign is not the last element in the pattern
  not regex.lastItem(position, position + 1)
}

// Query for regular expressions containing problematic dollar signs
from RegExp regex, int pos
where unmatchable_dollar(regex, pos)
select regex,
  "This regular expression includes an unmatchable dollar at offset " + pos.toString() + "."