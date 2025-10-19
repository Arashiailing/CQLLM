/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Identifies Paramiko SSH client configurations that accept unknown host keys, potentially enabling man-in-the-middle attacks.
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

// Define a helper to retrieve insecure Paramiko host key policies that blindly accept unknown keys
private API::Node retrieveInsecureHostKeyPolicy(string insecurePolicyName) {
  // Target both AutoAddPolicy and WarningPolicy from paramiko.client or paramiko module
  insecurePolicyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(insecurePolicyName)
    or
    result = API::moduleImport("paramiko").getMember(insecurePolicyName)
  )
}

// Obtain references to Paramiko SSHClient instances from either paramiko.client or paramiko module
private API::Node fetchSshClientInstance() {
  // Support both paramiko.client.SSHClient and paramiko.SSHClient access patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Identify calls to set_missing_host_key_policy with insecure arguments
from DataFlow::CallCfgNode cfgNode, DataFlow::Node hostKeyPolicyArg, string insecurePolicyName
where
  // Documentation reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  // Locate calls to set_missing_host_key_policy on SSHClient instances
  cfgNode = fetchSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  // Extract policy argument from either positional or named parameter
  hostKeyPolicyArg in [cfgNode.getArg(0), cfgNode.getArgByName("policy")] and
  // Verify if argument corresponds to insecure policy values or their return values
  (
    hostKeyPolicyArg = retrieveInsecureHostKeyPolicy(insecurePolicyName).getAValueReachableFromSource()
    or
    hostKeyPolicyArg = retrieveInsecureHostKeyPolicy(insecurePolicyName).getReturn().getAValueReachableFromSource()
  )
select cfgNode, "Setting missing host key policy to " + insecurePolicyName + " may be unsafe."