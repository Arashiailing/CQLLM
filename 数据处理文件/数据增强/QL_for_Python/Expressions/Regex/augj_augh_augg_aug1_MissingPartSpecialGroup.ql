/**
 * @name Incomplete named group in regular expression
 * @description Detects regular expressions with malformed named group syntax.
 *              The opening parenthesis omits the required '?' character,
 *              causing the group to be treated as a standard capturing group
 *              instead of a named group, resulting in unintended matching behavior.
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

from RegExp problematicRegex, string requiredChar, string groupCategory
where 
  // Identify regex patterns with incomplete named group syntax
  exists(string patternContent | 
    patternContent = problematicRegex.getText() and 
    patternContent.regexpMatch(".*\\(P<\\w+>.*")
  ) and
  // Specify the missing character needed for proper named group syntax
  requiredChar = "?" and 
  // Define the type of group affected by the syntax error
  groupCategory = "named group"
select problematicRegex, "Regular expression is missing '" + requiredChar + "' in " + groupCategory + "."