/**
 * @name Command Line Injection
 * @description Execution of commands incorporating user-controlled input enables
 *              attackers to manipulate command behavior via malicious inputs.
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

// Define tainted source and command execution sink nodes
from CommandInjectionFlow::PathNode taintedSource, CommandInjectionFlow::PathNode executionSink
// Ensure data flows from tainted source to command execution sink
where CommandInjectionFlow::flowPath(taintedSource, executionSink)
// Report command execution point with taint path details
select executionSink.getNode(), taintedSource, executionSink, 
       "This command execution depends on a $@.", taintedSource.getNode(),
       // Identify the source of untrusted input
       "user-provided value"