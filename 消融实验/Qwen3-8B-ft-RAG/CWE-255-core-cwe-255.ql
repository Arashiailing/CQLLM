/**
 * @name Credentials Management Errors
 * @description nan
 * @kind path-problem
 * @problem.severity recommendation
 * @tags security
 *       experimental
 *       external/cwe/cwe-255
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.security.dataflow.PasswordManagementFlow
import CredentialsManagementFlow::PathGraph
import CredentialsManagementFlow::FlowConfig

// 定义数据流源节点和汇节点
from CredentialsManagementFlow::PathNode source, CredentialsManagementFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
where CredentialsManagementFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息、描述信息等
select sink.getNode(), source, sink, "Credential $@.", source.getNode(), "user-provided value"