/**
 * @name Acceptance of unknown SSH host keys in Paramiko
 * @description Accepting unknown host keys without validation can lead to man-in-the-middle attacks.
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

// Represents API nodes corresponding to insecure Paramiko host key policies
private API::Node getInsecurePolicyNode(string policyTypeName) {
  // Matches AutoAddPolicy or WarningPolicy from paramiko.client or paramiko module
  policyTypeName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyTypeName)
    or
    result = API::moduleImport("paramiko").getMember(policyTypeName)
  )
}

// Represents API nodes that are instances of Paramiko SSHClient
private API::Node getSSHClientInstance() {
  // Handles both paramiko.client.SSHClient and paramiko.SSHClient patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects unsafe host key policy configurations
from DataFlow::CallCfgNode cfgNode, DataFlow::Node argumentNode, string policyTypeName
where
  // Verifies the call is to set_missing_host_key_policy on an SSHClient instance
  cfgNode = getSSHClientInstance().getMember("set_missing_host_key_policy").getACall()
  and
  // Identifies the policy argument (either by position or by name)
  argumentNode in [cfgNode.getArg(0), cfgNode.getArgByName("policy")]
  and
  // Checks if the argument references an insecure policy
  (
    argumentNode = getInsecurePolicyNode(policyTypeName).getAValueReachableFromSource()
    or
    argumentNode = getInsecurePolicyNode(policyTypeName).getReturn().getAValueReachableFromSource()
  )
select cfgNode, "Setting missing host key policy to " + policyTypeName + " may be unsafe."