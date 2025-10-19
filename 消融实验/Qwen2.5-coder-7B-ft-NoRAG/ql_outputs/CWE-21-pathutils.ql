/**
 * @name CWE CATEGORY: DEPRECATED: Pathname Traversal and Equivalence Errors
 * @description Pathname traversal and equivalence errors occur when an application constructs a pathname using untrusted input, which could lead to unintended access to files outside the intended directory.
 * @id py/pathutils
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where PathInjectionFlow::flowPath(source, sink) and sink.getNode() = externalApi.getUntrustedDataNode()
select sink.getNode(), source, sink, "Potential pathname traversal vulnerability due to untrusted data: " + externalApi.toString(), source.getNode(), source.toString()