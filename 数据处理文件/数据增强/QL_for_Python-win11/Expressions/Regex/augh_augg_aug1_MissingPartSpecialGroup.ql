/**
 * @name Incomplete named group in regular expression
 * @description Identifies regular expressions containing incomplete named group syntax.
 *              The opening parenthesis lacks the required '?' character, causing
 *              the group to be parsed as a normal capturing group instead of
 *              a named group. This leads to unexpected matching behavior.
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

from RegExp faultyRegExp, string missingChar, string groupType
where 
  // Capture regex patterns with incomplete named group syntax
  exists(string patternText | 
    patternText = faultyRegExp.getText() and 
    patternText.regexpMatch(".*\\(P<\\w+>.*")
  ) and
  // Define the missing character required for proper named group syntax
  missingChar = "?" and 
  // Specify the type of group affected by the syntax error
  groupType = "named group"
select faultyRegExp, "Regular expression is missing '" + missingChar + "' in " + groupType + "."