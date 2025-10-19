/**
 * @name Regular expression missing special group syntax
 * @description Detects incomplete special groups in regular expressions that are parsed as normal groups.
 *              Specifically identifies patterns with malformed named groups (missing '?') that may cause
 *              unintended matching behavior due to incorrect group interpretation.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group */

import python
import semmle.python.regex

from RegExp regExp, string missingChar, string groupCategory
where 
  regExp.getText().regexpMatch(".*\\(P<\\w+>.*") and 
  missingChar = "?" and 
  groupCategory = "named group"
select regExp, "Regular expression is missing '" + missingChar + "' in " + groupCategory + "."