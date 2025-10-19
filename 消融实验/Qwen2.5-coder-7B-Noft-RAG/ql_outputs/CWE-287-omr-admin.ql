/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
* @kind path-problem
* @problem.severity warning
*
@id py/omr-admin
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow predicate authenticatesImproperly(LdapBind ldapBind) { ( exists(LocalVariable lv | lv.getType().isSubtypeOf(ClassValue::str())
    and lv.hasInitializer(ldapBind.getPassword()))
    or ldapBind.getPassword().getType().isSubtypeOf(ClassValue::none()) ) }
from LdapBind ldapBind, LocalVariable authVar
    where authenticatesImproperly(ldapBind)
    and ldapBind.getPassword().asExpr() = authVar.asExpr()
    select ldapBind, authVar, "Improper authentication: User-controlled password is used."