/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects usage of Python 2's built-in 'input' function which evaluates input as executable code.
 *              This creates arbitrary code execution risks. Unlike 'raw_input()' that safely returns strings,
 *              'input()' in Python 2 interprets input as Python expressions, making it dangerous.
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

import python  // Core Python analysis library
import semmle.python.dataflow.new.DataFlow  // Data flow tracking capabilities
import semmle.python.ApiGraphs  // Built-in function API mappings

// Identify dangerous input() function calls through data flow analysis
from DataFlow::CallCfgNode dangerousInputFunctionCall
where
  // Ensure analysis targets Python 2 environment
  exists(int pyVersion | pyVersion = 2 and major_version() = pyVersion)
  and
  // Match calls to the built-in 'input' function
  dangerousInputFunctionCall = API::builtin("input").getACall()
  and
  // Exclude safe 'raw_input' function calls from results
  dangerousInputFunctionCall != API::builtin("raw_input").getACall()
select dangerousInputFunctionCall, "Python 2's 'input()' function evaluates input as code, creating arbitrary execution risks"