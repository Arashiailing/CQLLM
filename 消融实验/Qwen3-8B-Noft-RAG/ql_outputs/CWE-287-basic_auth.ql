/**
 * @name CWE-287: Improper Authentication
 * @id py/basic_auth
 */
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(BasicAuth auth) {
  // Check if the basic auth credential is stored in cleartext
  auth.getPassword().asExpr() instanceof StringLit or
  auth.getUsername().asExpr() instanceof StringLit or
  
  // Or check for direct use of user input in authorization header
  exists(DataFlow::Node src | 
    DataFlow::localFlow(src, auth.getPassword()) and 
    src.isFromUserInput()
  )
}

from BasicAuth auth
where authenticatesImproperly(auth)
select auth, "Cleartext storage or transmission of authentication credentials detected"