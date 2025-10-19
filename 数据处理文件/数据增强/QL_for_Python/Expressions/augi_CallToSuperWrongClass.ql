/**
 * @name First argument to super() is not enclosing class
 * @description Detects calls to super() where the first argument is not the enclosing class name,
 *              which may lead to incorrect object initialization.
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

// Identify calls to the built-in super() function
from DataFlow::CallCfgNode superCallNode, string enclosingClassName
where
  // Verify the node represents a call to the builtin super function
  superCallNode = API::builtin("super").getACall() and
  // Extract the name of the enclosing class where super() is called
  enclosingClassName = superCallNode.getScope().getScope().(Class).getName() and
  // Check if the first argument to super() is not the enclosing class name
  exists(DataFlow::Node firstArgNode |
    firstArgNode = superCallNode.getArg(0) and
    // Compare the argument's source identifier with the enclosing class name
    firstArgNode.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
// Report the problematic super() call with appropriate message
select superCallNode.getNode(), "First argument to super() should be " + enclosingClassName + "."