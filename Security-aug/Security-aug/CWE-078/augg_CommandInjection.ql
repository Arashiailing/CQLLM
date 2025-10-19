/**
 * @name Uncontrolled command line
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

// Import Python analysis libraries
import python

// Import security dataflow analysis for command injection detection
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph representation for command injection flows
import CommandInjectionFlow::PathGraph

// Identify untrusted sources and dangerous sinks in command execution
from CommandInjectionFlow::PathNode untrustedSource, CommandInjectionFlow::PathNode dangerousSink
// Verify data flow exists from untrusted source to dangerous sink
where CommandInjectionFlow::flowPath(untrustedSource, dangerousSink)
// Report results with flow path and vulnerability description
select dangerousSink.getNode(), untrustedSource, dangerousSink, 
       "This command line depends on a $@.", untrustedSource.getNode(),
       "user-provided value"