/**
* @name CWE-125: Path Injection
*
@description Accessing paths influenced by users can allow an attacker to access unexpected resources.
* @kind path-problem
* @problem.severity error
* @security-severity 7.5
* @sub-severity high
* @precision high
*
@id py/path-injection
*
@tags correctness * security * external/cwe/cwe-022 * external/cwe/cwe-023 * external/cwe/cwe-036 * external/cwe/cwe-073 * external/cwe/cwe-099
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"