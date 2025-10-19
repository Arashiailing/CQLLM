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

from RegExp regexPattern, string expectedChar, string groupCategory
where 
  /* Check for regex patterns containing incomplete named group syntax */
  exists(string patternText | 
    patternText = regexPattern.getText() and 
    patternText.regexpMatch(".*\\(P<\\w+>.*")
  ) and
  /* Identify the missing character causing the syntax issue */
  expectedChar = "?" and 
  /* Specify the type of group affected by the incomplete syntax */
  groupCategory = "named group"
select regexPattern, "Regular expression is missing '" + expectedChar + "' in " + groupCategory + "."