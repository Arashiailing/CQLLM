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

// Identify potentially dangerous function calls in Python 2 code
from DataFlow::CallCfgNode riskyInputCall
where
  // Restrict analysis to Python 2 environments
  major_version() = 2 and
  
  // Detect invocations of the 'input' built-in function
  riskyInputCall = API::builtin("input").getACall() and
  
  // Filter out calls to the safer 'raw_input' alternative
  riskyInputCall != API::builtin("raw_input").getACall()
  
select riskyInputCall, "Use of the unsafe built-in 'input' function detected in Python 2 code."  // Report the security issue with descriptive message