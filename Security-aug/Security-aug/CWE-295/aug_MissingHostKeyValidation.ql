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

// Identifies nodes representing insecure Paramiko host key policies
private API::Node insecurePolicyNode(string policyName) {
  // Matches AutoAddPolicy or WarningPolicy from paramiko.client or paramiko module
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Retrieves Paramiko SSHClient instance nodes
private API::Node sshClientInstanceNode() {
  // Handles both paramiko.client.SSHClient and paramiko.SSHClient patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects unsafe host key policy configurations
from DataFlow::CallCfgNode methodCall, DataFlow::Node policyArg, string policyName
where
  // Verifies call to set_missing_host_key_policy on SSHClient instance
  methodCall = sshClientInstanceNode().getMember("set_missing_host_key_policy").getACall() and
  // Identifies policy argument (position 0 or named 'policy')
  policyArg in [methodCall.getArg(0), methodCall.getArgByName("policy")] and
  // Checks if argument references insecure policy
  (
    policyArg = insecurePolicyNode(policyName).getAValueReachableFromSource()
    or
    policyArg = insecurePolicyNode(policyName).getReturn().getAValueReachableFromSource()
  )
select methodCall, "Setting missing host key policy to " + policyName + " may be unsafe."