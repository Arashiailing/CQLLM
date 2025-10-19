/**
 * @name Critical vulnerability: Python 2 'input' function usage
 * @description Detects dangerous usage of Python 2's built-in 'input' function.
 *              In Python 2, 'input()' executes user input as Python code, creating
 *              a severe code injection risk. This differs from 'raw_input()', which
 *              safely returns input as a string without execution.
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

// Detect vulnerable input function calls in Python 2 applications
from DataFlow::CallCfgNode vulnerableInputCall
where
  // Target only Python 2 codebases
  major_version() = 2
  and 
  // Identify calls to the dangerous 'input' builtin function
  vulnerableInputCall = API::builtin("input").getACall()
  and 
  // Ensure we're not flagging the safe 'raw_input' alternative
  vulnerableInputCall != API::builtin("raw_input").getACall()
select vulnerableInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."