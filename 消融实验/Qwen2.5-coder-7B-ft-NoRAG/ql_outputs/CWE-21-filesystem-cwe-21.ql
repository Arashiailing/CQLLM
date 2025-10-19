/**
 * @name CWE-21: Path Injection
 * @category Deprecated: Pathname Traversal and Equivalence Errors
 * @description Path injection occurs when untrusted data is used to construct file paths, allowing attackers to access unintended resources.
 * @id py/filesystem-cwe-21
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential path injection vulnerability due to use of untrusted data in file path construction."