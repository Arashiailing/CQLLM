/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects usage of the built-in 'input' function in Python 2 code.
 *              In Python 2, 'input()' evaluates user input as Python code, creating a code injection vulnerability.
 *              Unlike the safe 'raw_input()' which returns a string, 'input()' can execute arbitrary code.
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
from DataFlow::CallCfgNode dangerousInputUsage
where
  // Restrict analysis to Python 2 code
  major_version() = 2
  and
  // Identify calls to the unsafe 'input' function
  dangerousInputUsage = API::builtin("input").getACall()
  and
  // Exclude calls to the safe 'raw_input' function
  dangerousInputUsage != API::builtin("raw_input").getACall()
select dangerousInputUsage, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."