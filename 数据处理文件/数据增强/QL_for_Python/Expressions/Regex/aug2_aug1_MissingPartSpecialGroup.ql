/**
 * @name Incomplete special group in regular expression
 * @description Detects incomplete named groups in regex patterns where the '?' is missing after '('.
 *              Such groups are parsed as literal parentheses instead of special groups,
 *              leading to unintended matching behavior.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group
 */

import python
import semmle.python.regex

from RegExp regExpr, string missingCharacter, string groupNameType
where 
  /* Identify regex patterns containing incomplete named group syntax */
  regExpr.getText().regexpMatch(".*\\(P<\\w+>.*") and
  /* Specify the missing character that causes the issue */
  missingCharacter = "?" and 
  /* Define the type of group being affected */
  groupNameType = "named group"
select regExpr, "Regular expression is missing '" + missingCharacter + "' in " + groupNameType + "."