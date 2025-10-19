/**
 * @name CWE-88: Improper Neutralization of Argument Delimiters in a Command ('Argument Injection')
 * @description Detects instances where untrusted user inputs are used in subprocess commands without proper sanitization,
 *             which could enable attackers to inject arbitrary command arguments.
 * @id py/apkleaks-cwe-88
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 9.8
 * @tags security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

// Import core Python analysis library
import python

// Import specialized module for identifying command injection vulnerabilities
import experimental.apkleaks.command.InjectionCommandFlows

// Define source and sink nodes for data flow tracking
from InjectionCommandFlows::PathNode taintedSource, InjectionCommandFlows::PathNode sanitizedSink

// Verify existence of data flow path from user input to command execution point
where InjectionCommandFlows::flowPath(taintedSource, sanitizedSink)

// Generate alert with detailed context about unsafe command construction
select sanitizedSink.getNode(), 
       taintedSource, 
       sanitizedSink, 
       "This command line depends on a $@.", 
       taintedSource.getNode(), 
       "user-provided value"