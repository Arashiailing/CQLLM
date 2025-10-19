/**
 * @name First argument to super() is not enclosing class
 * @description Detects super() calls where the first parameter doesn't match
 *              the containing class, which may lead to incorrect initialization.
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

from DataFlow::CallCfgNode superInvocation, string enclosingClassName
where
  // Identify all super() function calls in the codebase
  superInvocation = API::builtin("super").getACall() and
  // Extract the name of the class containing the super() invocation
  enclosingClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Verify that a first argument exists and doesn't match the enclosing class
  exists(DataFlow::Node firstArg |
    firstArg = superInvocation.getArg(0) and
    // Compare the argument's identifier against the enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
select superInvocation.getNode(), 
       "First argument to super() should be " + enclosingClassName + "."