/**
* @name CWE-362: Path Injection Query
*
@description Detects potential path injection vulnerabilities in Python code.
* @kind path-problem
* @problem.severity error
* @security-severity 7.5
* @precision high
*
@id py/path-injection
*
@tags security
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Call to " + externalApi.toString() + " with untrusted data
from $@.", source.getNode(), source.toString()