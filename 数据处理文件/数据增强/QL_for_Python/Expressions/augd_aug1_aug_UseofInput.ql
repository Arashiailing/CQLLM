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

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Identify unsafe input function calls in Python 2 code
from DataFlow::CallCfgNode inputCallNode
where
  // Target Python 2 environments where input() is dangerous
  major_version() = 2
  and
  // Match calls to the built-in input function
  inputCallNode = API::builtin("input").getACall()
  and
  // Explicitly exclude safe raw_input() calls
  inputCallNode != API::builtin("raw_input").getACall()
select inputCallNode, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."