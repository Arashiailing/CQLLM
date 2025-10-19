/**
 * @name Unmatchable caret in regular expression
 * @description Regular expressions containing a caret '^' in the middle cannot be matched, whatever the input.
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

// Identify regular expressions with unmatchable caret characters
// that appear in non-starting positions without MULTILINE/VERBOSE modes
from RegExp pattern, int offset
where 
  // Exclude regex patterns enabling MULTILINE mode (where ^ matches line start)
  not pattern.getAMode() = "MULTILINE" and
  // Exclude regex patterns enabling VERBOSE mode (where whitespace is ignored)
  not pattern.getAMode() = "VERBOSE" and
  // Confirm caret character exists at the specified position
  pattern.specialCharacter(offset, offset + 1, "^") and
  // Ensure caret is not positioned at the start of the regex pattern
  not pattern.firstItem(offset, offset + 1)
select pattern,
  "This regular expression includes an unmatchable caret at offset " + offset.toString() + "."