/**
 * @name Missing part of special group in regular expression
 * @description Detects incomplete special groups in regex patterns that are parsed as normal groups,
 *              leading to unintended string matching behavior.
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

from RegExp regexObj, string missingChar, string groupType
where 
  // Identify regex patterns containing incomplete named group syntax
  regexObj.getText().regexpMatch(".*\\(P<\\w+>.*")
  and missingChar = "?"
  and groupType = "named group"
select 
  regexObj, 
  "Regular expression is missing '" + missingChar + "' in " + groupType + "."