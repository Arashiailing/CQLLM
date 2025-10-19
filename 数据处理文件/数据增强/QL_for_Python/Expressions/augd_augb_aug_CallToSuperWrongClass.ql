/**
 * @name First argument to super() is not enclosing class
 * @description Identifies super() invocations where the initial parameter 
 *              does not reference the containing class, potentially causing 
 *              improper object initialization.
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

from DataFlow::CallCfgNode superCallNode, string containerClassName
where
  // Locate all super() function calls in the codebase
  superCallNode = API::builtin("super").getACall() and
  // Determine the name of the enclosing class by navigating up the scope hierarchy
  containerClassName = superCallNode.getScope().getScope().(Class).getName() and
  // Check that the first argument exists and does not match the enclosing class
  exists(DataFlow::Node primaryArgument |
    primaryArgument = superCallNode.getArg(0) and
    // Compare the identifier of the first argument with the enclosing class name
    primaryArgument.getALocalSource().asExpr().(Name).getId() != containerClassName
  )
select superCallNode.getNode(), 
       "First argument to super() should be " + containerClassName + "."