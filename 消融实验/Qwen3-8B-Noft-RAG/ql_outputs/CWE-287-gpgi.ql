import python
import semmle.python.security.dataflow.PamAuthorizationQuery
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

from Call c
where c.getFunction().getName() = "pam_authenticate"
  and not exists(Call c2 | 
    c2.getFunction().getName() = "pam_acct_mgmt" 
    and c2.getLocation().getFile() = c.getLocation().getFile()
  )
select c, "PAM authentication lacks subsequent account management verification."