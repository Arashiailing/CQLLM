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

// 获取存在安全风险的Paramiko主机密钥策略类节点
private API::Node getUnsafeHostKeyPolicyNode(string policyType) {
  policyType in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyType)
    or
    result = API::moduleImport("paramiko").getMember(policyType)
  )
}

// 获取Paramiko SSHClient实例的构造节点
private API::Node getSSHClientConstructorNode() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// 检测不安全的主机密钥策略配置
from DataFlow::CallCfgNode policySettingCall, string unsafePolicyType, DataFlow::Node policyArgument
where
  // 确认调用set_missing_host_key_policy方法
  policySettingCall = getSSHClientConstructorNode().getMember("set_missing_host_key_policy").getACall() and
  // 获取策略参数（位置参数或关键字参数）
  (
    policyArgument = policySettingCall.getArg(0) 
    or 
    policyArgument = policySettingCall.getArgByName("policy")
  ) and
  // 策略类型为不安全类型
  unsafePolicyType in ["AutoAddPolicy", "WarningPolicy"] and
  // 验证策略参数来源于不安全策略节点
  (
    policyArgument = getUnsafeHostKeyPolicyNode(unsafePolicyType).getAValueReachableFromSource()
    or
    policyArgument = getUnsafeHostKeyPolicyNode(unsafePolicyType).getReturn().getAValueReachableFromSource()
  )
select policySettingCall, "Setting missing host key policy to " + unsafePolicyType + " may be unsafe."