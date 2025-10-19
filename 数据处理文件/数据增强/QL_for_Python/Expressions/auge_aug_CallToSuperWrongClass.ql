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

from DataFlow::CallCfgNode superInvocation, string parentClassName
where
  // Identify all calls to the built-in super() function
  superInvocation = API::builtin("super").getACall() and
  // Extract the name of the enclosing class where super() is called
  parentClassName = superInvocation.getScope().getScope().(Class).getName() and
  // Check if there's a first argument and it's not the enclosing class
  exists(DataFlow::Node initialArgument |
    initialArgument = superInvocation.getArg(0) and
    // Compare the identifier of the first argument with the enclosing class name
    initialArgument.getALocalSource().asExpr().(Name).getId() != parentClassName
  )
select superInvocation.getNode(), "First argument to super() should be " + parentClassName + "."