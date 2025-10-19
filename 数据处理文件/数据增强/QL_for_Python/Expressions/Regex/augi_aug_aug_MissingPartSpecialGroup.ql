/**
 * @name Regular expression missing special group syntax
 * @description Identifies regular expressions containing incomplete special group syntax that are parsed as normal groups.
 *              Specifically detects malformed named groups (missing '?') which may cause unintended matching behavior
 *              due to incorrect group interpretation.
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
  regexPattern.getText().regexpMatch(".*\\(P<\\w+>.*") and 
  expectedChar = "?" and 
  groupType = "named group"
select regexPattern, "Regular expression is missing '" + expectedChar + "' in " + groupType + "."