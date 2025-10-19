/**
 * @name First argument to super() is not enclosing class
 * @description Identifies super() invocations where the first argument does not refer to 
 *              the immediately enclosing class, potentially causing incorrect initialization 
 *              of the inheritance chain.
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

from DataFlow::CallCfgNode superCall, string immediateEnclosingClassName
where
  // Identify all super() function invocations in the codebase
  superCall = API::builtin("super").getACall()
  and
  // Determine the name of the class directly containing the super() call
  immediateEnclosingClassName = superCall.getScope().getScope().(Class).getName()
  and
  // Verify that the first argument exists and does not match the enclosing class name
  exists(DataFlow::Node firstArg |
    firstArg = superCall.getArg(0)
    and
    // Compare the argument's identifier against the enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != immediateEnclosingClassName
  )
select superCall.getNode(), 
       "First argument to super() should be " + immediateEnclosingClassName + "."