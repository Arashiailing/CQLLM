/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description A program constructs a filename from untrusted input before verifying
 *              that the resulting pathname refers to a target file inside a safe directory,
 *              enabling directory traversal attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision medium
 * @id py/jail
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import semmle.python.security.dataflow.JailEscapeQuery
import JailEscapeFlow::PathGraph

from JailEscapeFlow::PathNode source, JailEscapeFlow::PathNode sink
where JailEscapeFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "File access depends on a $@.", source.getNode(),
  "user-controlled input"