import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @id py/0004_auto_20200810_1111
 */

predicate authenticatesImproperly(Authentication auth) {
  // Check if authentication method lacks proper verification mechanism
  auth.getVerificationMechanism() = null or
  auth.getVerificationMechanism().isWeak()
}

from Authentication auth
where authenticatesImproperly(auth)
select auth, "Improper authentication mechanism detected"