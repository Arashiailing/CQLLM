/**
 * @name Uncontrolled command line
 * @description Detects execution of system commands that incorporate user-controlled input,
 *              which could allow attackers to inject malicious commands.
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

// Import core Python language analysis capabilities
import python

// Import specialized security dataflow framework for detecting command injection vulnerabilities
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph utilities for visualizing data flow paths from source to sink
import CommandInjectionFlow::PathGraph

// Identify potential command injection by tracking data flow from malicious input to command execution
from CommandInjectionFlow::PathNode maliciousInput, CommandInjectionFlow::PathNode commandExecutionTarget
// Ensure there exists a complete data flow path connecting the malicious input source to the command execution target
where CommandInjectionFlow::flowPath(maliciousInput, commandExecutionTarget)
// Report the vulnerability with detailed context about the data flow
select commandExecutionTarget.getNode(), maliciousInput, commandExecutionTarget, 
       "This command line depends on a $@.", maliciousInput.getNode(),
       "user-provided value"