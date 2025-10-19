/**
 * @name CWE-264: Command Injection
 * @description Executing commands constructed from user input can lead to command injection vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/core-cwe-264
 * @tags security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(), "user-provided value"