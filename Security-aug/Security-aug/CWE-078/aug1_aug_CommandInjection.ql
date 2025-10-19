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

// Define malicious input sources and vulnerable execution points
from CommandInjectionFlow::PathNode taintedInput, CommandInjectionFlow::PathNode vulnerableSink
// Verify data flow path exists from untrusted source to command execution
where CommandInjectionFlow::flowPath(taintedInput, vulnerableSink)
// Generate alert with execution point and taint flow details
select vulnerableSink.getNode(), taintedInput, vulnerableSink, 
       "This command execution depends on a $@.", taintedInput.getNode(),
       // Specify the origin of untrusted data
       "user-provided value"