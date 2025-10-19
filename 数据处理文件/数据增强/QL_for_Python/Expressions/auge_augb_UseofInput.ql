/**
 * @name Unsafe 'input' function usage in Python 2
 * @description Identifies calls to the built-in 'input' function in Python 2, which poses a security risk by executing arbitrary code.
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

import python  // Import the Python analysis library
import semmle.python.dataflow.new.DataFlow  // Import data flow analysis framework
import semmle.python.ApiGraphs  // Import API graph analysis tools

// Find all calls to the unsafe 'input' function in Python 2 code
from DataFlow::CallCfgNode inputInvocation
where
  // Limit the analysis scope to Python 2 environments only
  major_version() = 2 and
  
  // Identify calls to the 'input' built-in function
  inputInvocation = API::builtin("input").getACall() and
  
  // Exclude calls to the safe 'raw_input' alternative
  inputInvocation != API::builtin("raw_input").getACall()
  
select inputInvocation, "Use of the unsafe built-in 'input' function detected in Python 2 code."  // Report the security issue with descriptive message