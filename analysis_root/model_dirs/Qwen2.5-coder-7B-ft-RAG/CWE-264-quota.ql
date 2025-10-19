/**
 * @name CWE-264:Command Injection Query
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @sub-severity high
 * @id py/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),  "user-provided value"