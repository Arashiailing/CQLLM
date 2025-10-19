/**
 * @name 'input' function used in Python 2
 * @description Detects usage of the built-in 'input' function in Python 2, which can execute arbitrary code.
 * @kind problem
 * @tags security
 *       correctness
 *       security/cwe/cwe-94
 *       security/cwe/cwe-95
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/use-of-input
 */

import python  // Import Python library for code analysis
import semmle.python.dataflow.new.DataFlow  // Import data flow analysis capabilities
import semmle.python.ApiGraphs  // Import API graph analysis utilities

// Identify function call nodes that match our criteria
from DataFlow::CallCfgNode inputFunctionCall
where
  // Restrict analysis to Python 2 environment
  major_version() = 2 and
  
  // Find calls to the 'input' built-in function
  inputFunctionCall = API::builtin("input").getACall() and
  
  // Exclude calls to 'raw_input' which is the safe alternative
  inputFunctionCall != API::builtin("raw_input").getACall()
  
select inputFunctionCall, "The unsafe built-in function 'input' is used in Python 2."  // Report the finding with security message