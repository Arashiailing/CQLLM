/**
 * @name Incorrect first argument in super() call
 * @description Detects super() calls where the first argument is not the enclosing class,
 *              which can lead to improper object initialization.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 *       external/cwe/cwe-687
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/super-not-enclosing-class
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Define input variables: super() call node and enclosing class name
from DataFlow::CallCfgNode superCallNode, string enclosingClassName
where
  // Verify node is a call to the super built-in function
  superCallNode = API::builtin("super").getACall() and
  // Retrieve enclosing class name from current scope hierarchy
  enclosingClassName = superCallNode.getScope().getScope().(Class).getName() and
  // Validate first argument exists and mismatches enclosing class
  exists(DataFlow::Node firstArg |
    firstArg = superCallNode.getArg(0) and
    // Compare argument's identifier against enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
// Report issue with diagnostic message
select superCallNode.getNode(), "First argument to super() should be " + enclosingClassName + "."