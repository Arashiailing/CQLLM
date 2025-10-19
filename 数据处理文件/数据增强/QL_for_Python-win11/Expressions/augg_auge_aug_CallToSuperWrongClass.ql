/**
 * @name Incorrect super() first argument
 * @description Using a class other than the enclosing class as the first argument to super() 
 *              can lead to improper object initialization and inheritance issues.
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

from DataFlow::CallCfgNode superCall, string enclosingClassName
where
  // Identify all calls to the built-in super() function
  superCall = API::builtin("super").getACall() and
  // Extract the name of the enclosing class where super() is called
  enclosingClassName = superCall.getScope().getScope().(Class).getName() and
  // Verify that super() has a first argument that is not the enclosing class
  exists(DataFlow::Node firstArg |
    firstArg = superCall.getArg(0) and
    // Compare the identifier of the first argument with the enclosing class name
    firstArg.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
select superCall.getNode(), "First argument to super() should be " + enclosingClassName + "."