python
/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/cwe-287
*/
import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery
// 从PamAuthorizationFlow路径节点中选择源节点和汇节点
from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
// 条件：存在从源节点到汇节点的路径
    where PamAuthorizationFlow::flowPath(source, sink)
// 选择汇节点、源节点、汇节点，并生成警告信息
    select sink.getNode(), source, sink, "This PAM authentication depends on a $@,
    and 'pam_acct_mgmt' is not called afterwards.", source.getNode(), "user-provided value"