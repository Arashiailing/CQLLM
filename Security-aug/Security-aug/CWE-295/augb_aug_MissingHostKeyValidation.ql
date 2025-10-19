/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Detects when Paramiko SSH client is configured to accept unknown host keys,
 *              which can allow man-in-the-middle attacks by not verifying server identity.
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

// Identifies nodes representing insecure Paramiko host key policies
private API::Node insecureHostKeyPolicyNode(string unsafePolicyName) {
  // Matches AutoAddPolicy or WarningPolicy from paramiko.client or paramiko module
  unsafePolicyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(unsafePolicyName)
    or
    result = API::moduleImport("paramiko").getMember(unsafePolicyName)
  )
}

// Retrieves Paramiko SSHClient instance nodes
private API::Node paramikoSSHClientNode() {
  // Handles both paramiko.client.SSHClient and paramiko.SSHClient patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects unsafe host key policy configurations
from DataFlow::CallCfgNode policySettingCall, DataFlow::Node policyArgument, string unsafePolicyName
where
  // Verifies call to set_missing_host_key_policy on SSHClient instance
  policySettingCall = paramikoSSHClientNode().getMember("set_missing_host_key_policy").getACall() and
  // Identifies policy argument (position 0 or named 'policy')
  policyArgument in [policySettingCall.getArg(0), policySettingCall.getArgByName("policy")] and
  // Checks if argument references insecure policy
  (
    policyArgument = insecureHostKeyPolicyNode(unsafePolicyName).getAValueReachableFromSource()
    or
    policyArgument = insecureHostKeyPolicyNode(unsafePolicyName).getReturn().getAValueReachableFromSource()
  )
select policySettingCall, "Setting missing host key policy to " + unsafePolicyName + " may be unsafe."