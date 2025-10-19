/**
* @name CWE-20: Improper Input Validation
* @description The product receives input or data, but it does
*              not validate or incorrectly validates that the input has the
*              properties that are required to process the data safely and
*              correctly.
* @kind problem
* @id py/firewall
* @tags correctness
*       security
*       external/cwe/cwe-20
*/

import python
import semmle.python.ApiGraphs

from ClassObject firewallModule, Call securityCheck, int index
where
  firewallModule = API::moduleImport("firewall") and
  securityCheck = firewallModule.getMember("check").getACall() and
  index = securityCheck.getArg(0)
select securityCheck,
  "Call to deprecated function firewall.check may be insecure."