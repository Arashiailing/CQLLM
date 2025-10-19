/**
* @name Regex Injection Query
*
@description Regex injection occurs when user input is used to construct a regular expression, * allowing an attacker to manipulate the regex pattern
    and potentially execute arbitrary code.
* @kind path-problem
* @problem.severity error
* @security-severity 9.1
* @precision high
*
@id py/regex
*
@tags security
*/
import python
import semmle.python.security.dataflow.RegexInjectionQuery
import RegexInjectionFlow::PathGraph
from RegexInjectionFlow::PathNode source, RegexInjectionFlow::PathNode sink
    where RegexInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Regular expression is constructed
from a $@.", source.getNode(), "user-supplied input"