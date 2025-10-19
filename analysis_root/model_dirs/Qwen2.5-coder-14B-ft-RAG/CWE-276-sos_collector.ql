/**
 * @name TarSlip: Incorrect default permissions
 * @description This rule identifies vulnerabilities where the tar.extractall() method is invoked without specifying the 'embers'
 *              parameter. When omitted, this omission could enable attackers to overwrite arbitrary system files via path traversal,
 *              thereby escalating to a full system compromise.
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @precision high
 * @security-severity 7.5
 * @tags security
 *       external/cwe/cwe-022
 */

// Import necessary Python analysis libraries
import python
import semmle.python.ApiGraphs

// Import specialized TarSlip vulnerability detection utilities
import semmle.python.security.dataflow.TarSlipQuery

// Define the source (untrusted input origin) and target (method invocation point)
from TarSlipFlow::PathNode taintedInputOrigin, TarSlipFlow::PathNode unsafeMethodInvocation
where 
  // Verify existence of data flow path from user input to method invocation
  TarSlipFlow::flowPath(taintedInputOrigin, unsafeMethodInvocation)
select 
  // Identify the vulnerable method invocation location
  unsafeMethodInvocation.getNode(), 
  // Provide the source of untrusted data
  taintedInputOrigin, 
  // Trace the propagation path of untrusted data
  unsafeMethodInvocation, 
  // Generate detailed security alert message
  "This file extraction operation relies on a $@.", 
  // Reference the original data source node
  taintedInputOrigin.getNode(),
  // Describe the nature of the tainted input
  "user-provided value"