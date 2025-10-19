/**
* @name CWE-21: Path Injection
*
@description Path injection vulnerabilities occur when untrusted data is used to construct a pathname, * which could allow an attacker to access unintended resources.
* @kind path-problem
* @problem.severity error
* @security-severity 7.5
* @precision high
*
@id py/path-injection
*
@tags correctness * security * external/cwe/cwe-21
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Call to unsafe function with untrusted data
from $@.", source.getNode(), source.toString()