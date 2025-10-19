import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(LdapBind ldapBind) {
  exists(LocalDataFlow::LocalPath p |
    p.getSource() = None &&
    p.getDestination() = ldapBind.getPassword() &&
    p.isDirect()
  ) or
  ldapBind.getPassword() = null
}

from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "Improper authentication mechanism detected"