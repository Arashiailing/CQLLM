/**
 * @name CWE-269: Improper Privilege Management
 * @description The product does not properly assign, modify, track, or check privileges for an actor, creating an unintended sphere of control for that actor.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/catalog
 * @tags correctness
 *       security
 *       external/cwe/cwe-269
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.strings

// 定义一个数据流节点，表示对setUserPrivileges方法的调用
from DataFlow::CallCfgNode call_to_set_user_privileges, string priv, string obj
// 条件是临时名称函数返回的结果与当前调用节点c相匹配
where 
  call_to_set_user_privileges = API::moduleImport("privileges").getMember("setUserPrivileges").getACall() and
  priv = call_to_set_user_privileges.getArg(0).getAStringLiteral().getText() and
  obj = call_to_set_user_privileges.getScope().getScope().(Class).getName()
// 选择调用节点c，并生成警告信息，指出调用了可能不安全的setUserPrivileges方法
select call_to_set_user_privileges.asExpr(), "Call to deprecated method setUserPrivileges may be insecure."