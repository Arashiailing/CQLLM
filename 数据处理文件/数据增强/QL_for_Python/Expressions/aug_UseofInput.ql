/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects the usage of the built-in 'input' function in Python 2, which can execute arbitrary code.
 *              In Python 2, 'input()' evaluates the input as Python code, creating a code injection vulnerability.
 *              This is different from 'raw_input()' which safely returns a string.
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

// Select call configuration nodes from the data flow analysis library
from DataFlow::CallCfgNode inputFunctionCall
where
  // Only analyze code in Python 2 version
  major_version() = 2 and
  // Find calls to the built-in 'input' function
  inputFunctionCall = API::builtin("input").getACall() and
  // Ensure it's not a call to 'raw_input' which is safe
  inputFunctionCall != API::builtin("raw_input").getACall()
select inputFunctionCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."