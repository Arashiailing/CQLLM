/**
 * @name Incomplete special group in regular expression
 * @description An incomplete special group is parsed as a normal group and is unlikely to match the intended strings.
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

from RegExp regexPattern, string missingChar, string groupType
where 
  regexPattern.getText().regexpMatch(".*\\(P<\\w+>.*") and
  missingChar = "?" and 
  groupType = "named group"
select regexPattern, "Regular expression is missing '" + missingChar + "' in " + groupType + "."