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
private API::Node getSSHClientInstance() {
  // Handles both paramiko.client.SSHClient and paramiko.SSHClient patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects unsafe host key policy configurations
from DataFlow::CallCfgNode policyCall, DataFlow::Node policyArg, string insecurePolicyName
where
  // Verifies call to set_missing_host_key_policy on SSHClient instance
  policyCall = getSSHClientInstance().getMember("set_missing_host_key_policy").getACall()
  // Identifies policy argument (position 0 or named 'policy')
  and policyArg in [policyCall.getArg(0), policyCall.getArgByName("policy")]
  // Checks if argument references insecure policy
  and (
    policyArg = getInsecurePolicyNode(insecurePolicyName).getAValueReachableFromSource()
    or
    policyArg = getInsecurePolicyNode(insecurePolicyName).getReturn().getAValueReachableFromSource()
  )
select policyCall, "Setting missing host key policy to " + insecurePolicyName + " may be unsafe."