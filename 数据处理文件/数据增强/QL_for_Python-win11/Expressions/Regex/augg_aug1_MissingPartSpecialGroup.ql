/**
 * @name Incomplete special group in regular expression
 * @description Detects regular expressions with incomplete named groups
 *              where the opening parenthesis is missing the required '?' character.
 *              Such groups are parsed as normal groups instead of named groups,
 *              leading to unexpected matching behavior.
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

from RegExp incompleteRegex, string missingCharacter, string groupNameType
where 
  // Identify regex patterns containing incomplete named group syntax
  incompleteRegex.getText().regexpMatch(".*\\(P<\\w+>.*") and
  // Specify the missing character that makes the group incomplete
  missingCharacter = "?" and 
  // Define the type of group being affected
  groupNameType = "named group"
select incompleteRegex, "Regular expression is missing '" + missingCharacter + "' in " + groupNameType + "."