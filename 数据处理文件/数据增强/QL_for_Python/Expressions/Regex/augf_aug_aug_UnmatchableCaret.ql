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

/**
 * Determines whether a regular expression pattern contains a caret ('^') that cannot be matched
 * at a given position. This occurs when the caret is not at the start of the pattern and
 * the pattern is not in MULTILINE or VERBOSE mode, which would allow the caret to match
 * at the beginning of each line.
 */
predicate contains_unmatchable_caret(RegExp regexPattern, int caretPosition) {
  // Verify the regex mode doesn't allow mid-pattern caret matching
  not regexPattern.getAMode() = "MULTILINE" and
  not regexPattern.getAMode() = "VERBOSE" and
  // Confirm presence of caret character at specified location
  regexPattern.specialCharacter(caretPosition, caretPosition + 1, "^") and
  // Ensure caret isn't at pattern start position
  not regexPattern.firstItem(caretPosition, caretPosition + 1)
}

// Identify all regular expressions with unmatchable carets
from RegExp problematicRegex, int caretOffset
where contains_unmatchable_caret(problematicRegex, caretOffset)
select problematicRegex,
  "This regular expression includes an unmatchable caret at offset " + caretOffset.toString() + "."