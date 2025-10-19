import semmle.python.security.dataflow.PyDataFlow
import semmle.code.cpp.commons.Strings
import semmle.python.PyStrings
import semmle.python.PyCall
import semmle.python.PyRegex

from RegexPattern pattern, StringLiteral literal
where 
  (literal.getStringValue().matches("^[^\\d]*\$$") or 
   literal.getStringValue().matches("^(\$$[^\$$]+\$$")) and 
  pattern.getExpression() = literal
select pattern, "Potential CWE-400 vulnerability due to uncontrolled regex complexity"