/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Failing to verify SSH host keys enables potential man-in-the-middle attacks.
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

// Get Paramiko policy implementations that automatically accept unknown host keys
private API::Node getInsecureHostKeyPolicy(string policyClassName) {
  policyClassName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyClassName)
    or
    result = API::moduleImport("paramiko").getMember(policyClassName)
  )
}

// Identify Paramiko SSHClient class instances
private API::Node getSshClientObject() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detect unsafe host key policy configurations
from DataFlow::CallCfgNode policySettingCall, DataFlow::Node policyArg, string policyName
where
  // Target set_missing_host_key_policy method calls
  // Reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  policySettingCall = getSshClientObject().getMember("set_missing_host_key_policy").getACall() and
  
  // Identify policy argument (position 0 or named 'policy')
  policyArg in [policySettingCall.getArg(0), policySettingCall.getArgByName("policy")] and
  
  // Check if argument is an insecure policy
  (
    policyArg = getInsecureHostKeyPolicy(policyName).getAValueReachableFromSource() or
    policyArg = getInsecureHostKeyPolicy(policyName).getReturn().getAValueReachableFromSource()
  )
select policySettingCall, "Configuring host key policy with " + policyName + " creates security vulnerability."