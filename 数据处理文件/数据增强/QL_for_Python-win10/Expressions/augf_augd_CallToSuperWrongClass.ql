/**
 * @name First argument to super() is not enclosing class
 * @description Calling super with something other than the enclosing class may cause incorrect object initialization.
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

// Find super() calls with incorrect first argument
from DataFlow::CallCfgNode superCall, string enclosingClassName
where
  // Step 1: Identify super() function calls
  superCall = API::builtin("super").getACall() and
  
  // Step 2: Extract the enclosing class name
  enclosingClassName = superCall.getScope().getScope().(Class).getName() and
  
  // Step 3: Validate first argument exists and mismatches enclosing class
  exists(DataFlow::Node firstArgNode |
    // Locate the first argument node
    firstArgNode = superCall.getArg(0) and
    // Verify argument identifier differs from enclosing class name
    firstArgNode.getALocalSource().asExpr().(Name).getId() != enclosingClassName
  )
// Report findings with expected class name
select superCall.getNode(), "First argument to super() should be " + enclosingClassName + "."