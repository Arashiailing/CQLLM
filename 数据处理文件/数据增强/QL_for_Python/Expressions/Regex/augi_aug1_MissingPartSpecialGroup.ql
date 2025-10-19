/**
 * @name Incomplete special group in regular expression
 * @description Detects regular expressions with incomplete named group syntax. 
 *              When the '?' is missing before 'P<', the group is parsed as a 
 *              literal match instead of a named capture group, leading to 
 *              unintended behavior.
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

from RegExp pattern, string missingCharacter, string groupNameType
where 
  exists(string malformedGroup |
    malformedGroup = pattern.getText() and
    malformedGroup.regexpMatch(".*\\(P<\\w+>.*") and
    missingCharacter = "?" and 
    groupNameType = "named group"
  )
select pattern, "Regular expression is missing '" + missingCharacter + "' in " + groupNameType + "."