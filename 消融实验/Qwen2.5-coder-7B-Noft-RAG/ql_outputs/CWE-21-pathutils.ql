/**
* @name CWE-21: Path Injection
*
@description Path injection occurs when untrusted data is used in a path expression without proper validation
    or encoding.
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
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"