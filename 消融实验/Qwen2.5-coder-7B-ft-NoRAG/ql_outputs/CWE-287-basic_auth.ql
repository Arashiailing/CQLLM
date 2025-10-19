/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @id py/basic_auth
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(Authentication auth) {
  exists(Request req | req.getCredentials() = auth.getCredentials())
}

from Authentication auth
where authenticatesImproperly(auth)
select auth, "Basic authentication without proper verification."