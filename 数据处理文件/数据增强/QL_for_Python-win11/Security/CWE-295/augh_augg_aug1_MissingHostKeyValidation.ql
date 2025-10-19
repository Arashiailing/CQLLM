/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Detects configurations where Paramiko accepts unknown host keys,
 *              which could enable man-in-the-middle attacks.
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

// 获取接受未知主机密钥的不安全Paramiko策略类节点
private API::Node getInsecurePolicyNode(string policyName) {
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// 获取Paramiko SSHClient实例的构造节点
private API::Node getSshClientConstructor() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// 检测不安全的主机密钥策略配置
from DataFlow::CallCfgNode methodCall, string policyName, DataFlow::Node policyArg
where
  // 确认调用set_missing_host_key_policy方法
  methodCall = getSshClientConstructor().getMember("set_missing_host_key_policy").getACall() and
  // 获取策略参数（位置参数或关键字参数）
  (
    policyArg = methodCall.getArg(0) 
    or 
    policyArg = methodCall.getArgByName("policy")
  ) and
  // 策略名称为不安全类型
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  // 策略参数值来源于不安全策略节点
  (
    policyArg = getInsecurePolicyNode(policyName).getAValueReachableFromSource()
    or
    policyArg = getInsecurePolicyNode(policyName).getReturn().getAValueReachableFromSource()
  )
select methodCall, "Setting missing host key policy to " + policyName + " may be unsafe."