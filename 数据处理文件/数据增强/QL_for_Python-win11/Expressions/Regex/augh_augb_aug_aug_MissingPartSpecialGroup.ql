/**
 * @name Regular expression missing special group syntax
 * @description Detects incomplete special group syntax in regular expressions.
 *              Specifically identifies named groups missing the required '?' character
 *              after the opening parenthesis. This causes misinterpretation as regular
 *              capturing groups instead of named groups, leading to incorrect pattern
 *              matching and potential text processing bugs.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group */

import python
import semmle.python.regex

from RegExp pattern, string missingChar, string groupTypeName
where 
  // Verify malformed named group syntax (P<...>) without leading '?'
  pattern.getText().regexpMatch(".*\\(P<\\w+>.*") and 
  // Define the required character missing from special group syntax
  missingChar = "?" and 
  // Specify the affected group type by this syntax error
  groupTypeName = "named group"
select pattern, "Regular expression is missing '" + missingChar + "' in " + groupTypeName + "."