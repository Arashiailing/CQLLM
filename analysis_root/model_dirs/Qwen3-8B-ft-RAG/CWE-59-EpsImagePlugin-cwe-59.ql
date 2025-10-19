import python
import semmle.python.security.dataflow.PathInjectionQuery
import UntrustedDataToPathInjectionFlow::PathGraph

/**
 * @name Path Injection Vulnerability
 * @description Uncontrolled data used in path expressions can allow attackers to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/path-injection
 * @tags security
 *       correctness
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

from UntrustedDataToPathInjectionFlow::PathNode source, UntrustedDataToPathInjectionFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where
  sink.getNode() = externalApi.getUntrustedDataNode() and
  UntrustedDataToPathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-supplied value"