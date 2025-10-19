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

// Identify unsafe Paramiko host key policies
private API::Node getUnsafeParamikoPolicy(string policyName) {
  // Match either client module policies or direct module policies
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Retrieve Paramiko SSHClient instance sources
private API::Node getParamikoSshClientInstance() {
  // Handle both client.SSHClient and direct SSHClient access patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detect unsafe policy configurations
from DataFlow::CallCfgNode cfgNode, DataFlow::Node policyArg, string policyName
where
  // Reference: Paramiko SSHClient.set_missing_host_key_policy documentation
  // Identify calls to set_missing_host_key_policy method
  cfgNode = getParamikoSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  // Capture policy argument (position 0 or named 'policy')
  policyArg in [cfgNode.getArg(0), cfgNode.getArgByName("policy")] and
  // Check if argument resolves to unsafe policy
  (
    policyArg = getUnsafeParamikoPolicy(policyName).getAValueReachableFromSource()
    or
    policyArg = getUnsafeParamikoPolicy(policyName).getReturn().getAValueReachableFromSource()
  )
select cfgNode, "Setting missing host key policy to " + policyName + " may be unsafe."