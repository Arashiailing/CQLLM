import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "Improper authentication mechanism detected"