/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Accepting unknown host keys can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/paramiko-missing-host-key-validation
 * @tags security
 *       external/cwe/cwe-295
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// 定义一个私有函数，用于检测不安全的 Paramiko 策略
private API::Node unsafe_paramiko_policy(string name) {
  // 如果名称在 ["AutoAddPolicy", "WarningPolicy"] 中，并且是 paramiko 模块中的 client 成员或直接是 paramiko 模块的成员
  name in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(name)
    or
    result = API::moduleImport("paramiko").getMember(name)
  )
}

// 定义一个私有函数，用于获取 Paramiko SSHClient 实例
private API::Node paramikoSshClientInstance() {
  // 获取 paramiko.client.SSHClient 的返回值，或者直接获取 paramiko.SSHClient 的返回值
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// 从 DataFlow::CallCfgNode 和 DataFlow::Node 中选择调用节点和参数，并附加条件
from DataFlow::CallCfgNode call, DataFlow::Node arg, string name
where
  // 参考：http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  // 检查调用是否为 paramikoSshClientInstance 的 set_missing_host_key_policy 方法，并且参数匹配
  call = paramikoSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  arg in [call.getArg(0), call.getArgByName("policy")] and
  (
    // 检查参数是否为不安全策略的值或返回值
    arg = unsafe_paramiko_policy(name).getAValueReachableFromSource() or
    arg = unsafe_paramiko_policy(name).getReturn().getAValueReachableFromSource()
  )
select call, "Setting missing host key policy to " + name + " may be unsafe."
