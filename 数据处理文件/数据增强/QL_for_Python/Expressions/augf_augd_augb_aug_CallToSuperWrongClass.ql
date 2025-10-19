/**
 * @name First argument to super() is not enclosing class
 * @description Detects super() calls where the first parameter doesn't reference 
 *              the immediate containing class, which may lead to incorrect 
 *              inheritance chain initialization.
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
  // Traverse scope hierarchy to find the immediate containing class name
  enclosingClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Verify first argument exists and doesn't match the containing class
  exists(DataFlow::Node firstArgument |
    firstArgument = superInvocation.getArg(0) and
    // Compare argument's identifier against the containing class name
    firstArgument.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
select superInvocation.getNode(), 
       "First argument to super() should be " + enclosingClassName + "."