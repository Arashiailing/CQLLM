/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description This query identifies instances where the Paramiko SSH client is configured
 *              to accept unknown host keys without proper verification. Such configurations
 *              can expose applications to man-in-the-middle attacks by failing to validate
 *              the identity of the SSH server.
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
private API::Node getInsecurePolicyNode(string policyName) {
  // Matches AutoAddPolicy or WarningPolicy from paramiko.client or paramiko module
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Retrieves Paramiko SSHClient instance nodes
private API::Node getSSHClientNode() {
  // Handles both paramiko.client.SSHClient and paramiko.SSHClient patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects unsafe host key policy configurations
from DataFlow::CallCfgNode policySettingInvocation, DataFlow::Node policyParam, string policyName
where
  // Verifies call to set_missing_host_key_policy on SSHClient instance
  policySettingInvocation = getSSHClientNode().getMember("set_missing_host_key_policy").getACall() and
  // Identifies policy argument (position 0 or named 'policy')
  policyParam in [policySettingInvocation.getArg(0), policySettingInvocation.getArgByName("policy")] and
  // Checks if argument references insecure policy
  (
    policyParam = getInsecurePolicyNode(policyName).getAValueReachableFromSource()
    or
    policyParam = getInsecurePolicyNode(policyName).getReturn().getAValueReachableFromSource()
  )
select policySettingInvocation, "Setting missing host key policy to " + policyName + " may be unsafe."