/**
 * @name Unmatchable caret in regular expression
 * @description Identifies regular expressions containing a caret '^' in non-starting positions,
 *              making them incapable of matching any input string.
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

// Source: Extract regex patterns and their caret character positions
from RegExp patternExpr, int caretOffset
// Conditions for detecting unmatchable caret:
// - Caret character exists at the specified offset
// - Caret is not positioned at the pattern's start
// - MULTILINE mode is not enabled (which would allow caret to match line starts)
// - VERBOSE mode is not enabled (which might affect pattern interpretation)
where 
  // Verify caret character presence at the given offset
  patternExpr.specialCharacter(caretOffset, caretOffset + 1, "^") and
  // Ensure caret is not at the beginning of the pattern
  not patternExpr.firstItem(caretOffset, caretOffset + 1) and
  // Check that MULTILINE mode is disabled
  not patternExpr.getAMode() = "MULTILINE" and
  // Verify VERBOSE mode is not active
  not patternExpr.getAMode() = "VERBOSE"
// Result: Report the problematic regex with detailed diagnostic information
select patternExpr,
  "This regular expression contains an unmatchable caret at offset " + caretOffset.toString() + "."