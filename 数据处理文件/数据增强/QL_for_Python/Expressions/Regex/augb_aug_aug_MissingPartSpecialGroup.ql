/**
 * @name Regular expression missing special group syntax
 * @description Identifies regular expressions with incomplete special group syntax.
 *              This query specifically targets named groups that lack the required '?'
 *              character after the opening parenthesis, causing them to be interpreted
 *              as regular capturing groups instead of named groups. This misinterpretation
 *              can lead to incorrect pattern matching behavior and potential bugs in
 *              text processing logic.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group */

import python
import semmle.python.regex

from RegExp regexPattern, string expectedChar, string groupType
where 
  // Check if the regex pattern contains a malformed named group syntax (P<...>)
  regexPattern.getText().regexpMatch(".*\\(P<\\w+>.*") and 
  // Define the character that is missing from the special group syntax
  expectedChar = "?" and 
  // Specify the type of group that is affected by this syntax error
  groupType = "named group"
select regexPattern, "Regular expression is missing '" + expectedChar + "' in " + groupType + "."