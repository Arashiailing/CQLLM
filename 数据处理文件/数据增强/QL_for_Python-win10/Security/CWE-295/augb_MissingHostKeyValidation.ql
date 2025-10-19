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
from DataFlow::CallCfgNode methodCall, DataFlow::Node policyArg, string policyName
where
  // Reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  // Locates set_missing_host_key_policy calls on Paramiko SSHClient instances
  methodCall = getParamikoSshClient().getMember("set_missing_host_key_policy").getACall() and
  // Identifies policy arguments (both positional and keyword)
  policyArg in [methodCall.getArg(0), methodCall.getArgByName("policy")] and
  // Checks if argument references an insecure policy
  (
    policyArg = insecureParamikoPolicy(policyName).getAValueReachableFromSource() or
    policyArg = insecureParamikoPolicy(policyName).getReturn().getAValueReachableFromSource()
  )
select methodCall, "Configuring host key policy to " + policyName + " creates security vulnerability."