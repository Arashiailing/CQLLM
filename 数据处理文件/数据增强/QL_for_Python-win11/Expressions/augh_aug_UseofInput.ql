/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description This query identifies uses of the built-in 'input' function in Python 2 code.
 *              In Python 2, 'input()' evaluates the user input as Python code, creating a code injection risk.
 *              Unlike 'raw_input()' which safely returns a string, 'input()' can execute arbitrary code.
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

import python  // Import the Python library for analyzing Python code
import semmle.python.dataflow.new.DataFlow  // Import data flow analysis library
import semmle.python.ApiGraphs  // Import API graph analysis library

// Select call configuration nodes representing function calls
from DataFlow::CallCfgNode unsafeInputCall
where
  // Only analyze code in Python 2
  major_version() = 2
  and
  // Check if it's a call to the unsafe 'input' function
  unsafeInputCall = API::builtin("input").getACall()
  and
  // Ensure it's not a call to the safe 'raw_input' function
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."