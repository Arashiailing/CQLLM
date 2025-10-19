/**
 * @name Uncontrolled command line
 * @description This query identifies command execution operations that accept input
 *              from untrusted sources, which could allow attackers to inject
 *              malicious commands through manipulated input.
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

// Import core Python analysis framework
import python

// Import specialized dataflow tracking for command injection vulnerabilities
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph utilities for visualizing taint propagation
import CommandInjectionFlow::PathGraph

// Define flow path between untrusted input and command execution
from CommandInjectionFlow::PathNode taintedSource, CommandInjectionFlow::PathNode executionSink
where CommandInjectionFlow::flowPath(taintedSource, executionSink)
// Report command execution point with taint source details
select executionSink.getNode(), taintedSource, executionSink,
       "This command execution depends on a $@.", taintedSource.getNode(),
       // Describe the origin of untrusted input
       "user-provided value"