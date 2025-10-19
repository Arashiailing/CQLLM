/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Using Paramiko with unknown host key acceptance enables man-in-the-middle attacks.
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

// Identifies insecure Paramiko policy implementations
private API::Node insecureParamikoPolicy(string policyName) {
  // Matches either 'AutoAddPolicy' or 'WarningPolicy' from paramiko.client or paramiko module
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Retrieves Paramiko SSHClient instance nodes
private API::Node getParamikoSshClient() {
  // Captures both paramiko.client.SSHClient and paramiko.SSHClient instantiations
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects vulnerable host key policy configurations
from DataFlow::CallCfgNode policySettingCall, DataFlow::Node passedPolicyArg, string policyName
where
  // Locates set_missing_host_key_policy calls on Paramiko SSHClient instances
  policySettingCall = getParamikoSshClient().getMember("set_missing_host_key_policy").getACall() and
  // Identifies policy arguments (both positional and keyword)
  passedPolicyArg in [policySettingCall.getArg(0), policySettingCall.getArgByName("policy")] and
  // Checks if argument references an insecure policy
  (
    passedPolicyArg = insecureParamikoPolicy(policyName).getAValueReachableFromSource() or
    passedPolicyArg = insecureParamikoPolicy(policyName).getReturn().getAValueReachableFromSource()
  )
select policySettingCall, "Configuring host key policy to " + policyName + " creates security vulnerability."