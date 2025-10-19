/**
* @name CWE-264: Path Injection
* @category Permissions, Privileges,
    and Access Controls
*
@description Accessing paths influenced by users can allow an attacker to access unexpected resources.
*
@id py/path-injection
* @problem.severity error
* @security-severity 7.5
* @precision high
*
@tags correctness * security * external/cwe/cwe-022 * external/cwe/cwe-023 * external/cwe/cwe-036 * external/cwe/cwe-073 * external/cwe/cwe-099
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"