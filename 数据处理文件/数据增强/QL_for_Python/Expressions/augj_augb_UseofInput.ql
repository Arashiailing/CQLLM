/**
 * @name Python 2 'input' function usage
 * @description Identifies calls to the built-in 'input' function in Python 2, which evaluates user input as code, creating a code injection vulnerability.
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

import python  // Import Python language support for analysis
import semmle.python.dataflow.new.DataFlow  // Import data flow tracking functionality
import semmle.python.ApiGraphs  // Import API graph utilities for function identification

// Find all calls to the unsafe 'input' function in Python 2
from DataFlow::CallCfgNode unsafeInputCall
where
  // Check if we're analyzing Python 2 code
  major_version() = 2
  
  // Verify this is a call to the 'input' builtin
  and unsafeInputCall = API::builtin("input").getACall()
  
  // Exclude 'raw_input' calls which are safe
  and unsafeInputCall != API::builtin("raw_input").getACall()
  
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2."  // Flag the security issue with descriptive message