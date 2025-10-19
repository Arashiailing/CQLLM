/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Identifies calls to the built-in 'input' function in Python 2 code.
 *              In Python 2, 'input()' evaluates user input as Python code, creating a
 *              serious code injection vulnerability. This differs from 'raw_input()',
 *              which safely returns user input as a string without evaluation.
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
from DataFlow::CallCfgNode unsafeInputCall
where
  // Check if the code is written for Python 2
  major_version() = 2
  and
  // Identify calls to the built-in 'input' function
  unsafeInputCall = API::builtin("input").getACall()
  and
  // Exclude calls to 'raw_input' which is safe
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."