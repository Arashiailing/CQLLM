import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(LdapBind ldapBind) {
  (exists(DataFlow::LocalDataFlow ldf |
    ldf.getSource() = null &&
    ldf.getDestination() = ldapBind.getPassword()
  ) or
  ldapBind.getPassword() = null)
}

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink) and
  source.getNode().(LdapBind).includesUserInput() and
  authenticatesImproperly(source.getNode().(LdapBind))
select sink.getNode(), "Improper authentication detected in LDAP bind operation."