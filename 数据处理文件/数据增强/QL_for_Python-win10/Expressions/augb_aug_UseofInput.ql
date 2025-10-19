/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Identifies calls to the built-in 'input' function in Python 2 code.
 *              The 'input()' function in Python 2 evaluates user input as Python code,
 *              creating a critical code injection vulnerability. Unlike 'raw_input()',
 *              which safely returns a string without evaluation, 'input()' can execute
 *              arbitrary code provided by the user.
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

// Identify unsafe input function calls in Python 2 code
from DataFlow::CallCfgNode unsafeInputCall
where
  // Restrict analysis to Python 2 codebase
  major_version() = 2 and
  // Match calls to the built-in 'input' function
  unsafeInputCall = API::builtin("input").getACall() and
  // Exclude calls to 'raw_input' which is the safe alternative
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."