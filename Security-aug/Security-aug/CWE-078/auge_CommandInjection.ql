/**
 * @name Uncontrolled command line
 * @description Execution of commands with externally controlled input may enable
 *              attackers to manipulate command behavior through injection.
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

// Import Python language support for code analysis
import python

// Import security dataflow framework for command injection detection
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph representation for vulnerability flow visualization
import CommandInjectionFlow::PathGraph

// Define untrusted input source and command execution sink
from CommandInjectionFlow::PathNode untrustedSource, CommandInjectionFlow::PathNode commandSink
// Verify data flow path exists between source and sink
where CommandInjectionFlow::flowPath(untrustedSource, commandSink)
// Output vulnerability details with contextual information
select commandSink.getNode(), untrustedSource, commandSink, 
       "This command line depends on a $@.", untrustedSource.getNode(),
       "user-provided value"