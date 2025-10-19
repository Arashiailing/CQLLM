/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Detects when Paramiko SSH clients accept unknown host keys, which can enable man-in-the-middle attacks.
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

// Identify unsafe Paramiko host key policies that accept unknown keys
private API::Node getUnsafePolicy(string policyName) {
  // Match either AutoAddPolicy or WarningPolicy from paramiko.client or paramiko module
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Retrieve Paramiko SSHClient instances from either paramiko.client or paramiko module
private API::Node getSshClientInstance() {
  // Handle both paramiko.client.SSHClient and paramiko.SSHClient access patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detect calls to set_missing_host_key_policy with unsafe arguments
from DataFlow::CallCfgNode callNode, DataFlow::Node policyArg, string policyName
where
  // Reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  // Identify calls to set_missing_host_key_policy on SSHClient instances
  callNode = getSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  // Capture policy argument from either position or named parameter
  policyArg in [callNode.getArg(0), callNode.getArgByName("policy")] and
  // Check if argument matches unsafe policy values or return values
  (
    policyArg = getUnsafePolicy(policyName).getAValueReachableFromSource()
    or
    policyArg = getUnsafePolicy(policyName).getReturn().getAValueReachableFromSource()
  )
select callNode, "Setting missing host key policy to " + policyName + " may be unsafe."