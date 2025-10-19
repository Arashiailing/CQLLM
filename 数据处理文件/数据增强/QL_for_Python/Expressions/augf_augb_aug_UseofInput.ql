/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description This query identifies calls to the built-in 'input' function in Python 2 code.
 *              In Python 2, the 'input()' function evaluates user input as Python code,
 *              which introduces a critical code injection vulnerability. This behavior
 *              differs from 'raw_input()', which safely returns a string without evaluation.
 *              The use of 'input()' can allow attackers to execute arbitrary code provided
 *              as input, leading to potential security breaches including remote code execution.
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

// Identify dangerous input function calls in Python 2 code
from DataFlow::CallCfgNode vulnerableInputCall
where
  // First, ensure we are analyzing a Python 2 codebase
  major_version() = 2 and
  // Then, identify calls to the built-in 'input' function
  vulnerableInputCall = API::builtin("input").getACall() and
  // Finally, exclude calls to 'raw_input' which is the safe alternative
  not vulnerableInputCall = API::builtin("raw_input").getACall()
select vulnerableInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."