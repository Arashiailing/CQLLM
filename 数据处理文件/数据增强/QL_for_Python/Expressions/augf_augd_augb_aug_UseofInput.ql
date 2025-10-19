/**
 * @name Critical vulnerability: Python 2 'input' function usage
 * @description Identifies hazardous usage of Python 2's built-in 'input' function.
 *              In Python 2, 'input()' evaluates user input as Python code, creating
 *              a critical code injection vulnerability. This contrasts with 'raw_input()',
 *              which safely returns input as a string without evaluation.
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

// Identify dangerous input function calls in Python 2 applications
from DataFlow::CallCfgNode riskyInputCall
where
  // Restrict analysis to Python 2 codebases only
  major_version() = 2
  and 
  // Locate calls to the hazardous 'input' builtin function
  riskyInputCall = API::builtin("input").getACall()
  and 
  // Exclude the safe 'raw_input' alternative from detection
  riskyInputCall != API::builtin("raw_input").getACall()
select riskyInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."