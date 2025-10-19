/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/improper-authentication
*
@tags security * external/cwe/cwe-287
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
// 定义一个谓词函数，用于判断是否存在不当的身份验证predicate authenticatesImproperly(Authenticate authenticate) {
// 如果存在从任意None值到authenticate的局部数据流，或者authenticate没有设置用户名或密码，则返回true ( exists(DataFlow::LocalFlowNode local | local.getSource() instanceof NoneValue
    and local.getTarget() = authenticate )
    or authenticate.getUsername().asExpr() instanceof NoneValue
    or authenticate.getPassword().asExpr() instanceof NoneValue )}
from Authenticate auth
    where authenticatesImproperly(auth)
    select auth, "Improper authentication: The system does not properly verify the user's identity."