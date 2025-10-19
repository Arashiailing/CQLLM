/**
 * @name Uncontrolled command line
 * @description Execution of commands with externally controlled input may enable
 *              attackers to alter command behavior through malicious input.
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

// Import Python analysis framework
import python

// Import specialized security dataflow library for command injection detection
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph representation for taint flow visualization
import CommandInjectionFlow::PathGraph

// Identify untrusted input sources and command execution sinks
from CommandInjectionFlow::PathNode untrustedSource, CommandInjectionFlow::PathNode commandSink
// Where data flows from untrusted source to command execution sink
where CommandInjectionFlow::flowPath(untrustedSource, commandSink)
// Report command execution point with taint path details
select commandSink.getNode(), untrustedSource, commandSink, 
       "This command execution depends on a $@.", untrustedSource.getNode(),
       // Identify the source of untrusted input
       "user-provided value"