/**
 * @name Incomplete special group syntax in regular expressions
 * @description Identifies regex patterns with improperly formed special groups that are interpreted
 *              as literal groups, causing unexpected string matching behavior.
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

from RegExp regexPattern, string missingCharacter, string groupTypeName
where 
  // Detect regex patterns containing incomplete named group declarations
  regexPattern.getText().regexpMatch(".*\\(P<\\w+>.*")
  and missingCharacter = "?"
  and groupTypeName = "named group"
select 
  regexPattern, 
  "Regular expression is missing '" + missingCharacter + "' in " + groupTypeName + "."