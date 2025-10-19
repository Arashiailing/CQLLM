/**
 * @name Uncontrolled command line
 * @description Detects command execution using externally controlled inputs, which 
 *              could allow attackers to manipulate command behavior through crafted input.
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

// Import Python analysis capabilities
import python

// Import specialized dataflow tracking for command injection patterns
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path visualization for injection flow representation
import CommandInjectionFlow::PathGraph

// Identify vulnerable data flows from user inputs to command execution points
from CommandInjectionFlow::PathNode userInputOrigin, CommandInjectionFlow::PathNode commandExecutionPoint
// Validate complete data flow path exists between input and execution
where CommandInjectionFlow::flowPath(userInputOrigin, commandExecutionPoint)
// Generate security report with flow path and vulnerability context
select commandExecutionPoint.getNode(), userInputOrigin, commandExecutionPoint, 
       "Command execution incorporates a $@.", userInputOrigin.getNode(),
       "user-controlled input source"