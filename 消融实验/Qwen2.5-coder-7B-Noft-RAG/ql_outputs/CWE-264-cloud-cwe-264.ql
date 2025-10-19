python
/**
* @name CWE-264: Cleartext Storage of Sensitive Information
* @kind problem
* @problem.severity warning
* @precision medium
* @security-severity 7.5
*
@id py/cloud-cwe-264
*
@tags security
*/
import python
import semmle.python.security.informationflow.SensitiveData predicate isSensitiveDataStore(CFGNode node) { exists(SensitiveData::Flow flow | flow.getSource() = node) }
from CFGNode node, CFGNode caller
    where node.isMethodInvocation()
    and node.getMethodName() = "store"
    and caller = node.getParent()
    and caller.isMethodInvocation()
    and caller.getMethodName() = "print"
    and isSensitiveDataStore(caller)
    select node, "Storing sensitive data in cleartext."