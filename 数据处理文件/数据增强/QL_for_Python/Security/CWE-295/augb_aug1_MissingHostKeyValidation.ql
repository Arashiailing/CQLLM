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

// Retrieve Paramiko policy implementations that automatically accept unknown host keys
private API::Node retrieveInsecureHostKeyPolicy(string policyClassName) {
  policyClassName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyClassName)
    or
    result = API::moduleImport("paramiko").getMember(policyClassName)
  )
}

// Identify instances of Paramiko SSHClient class
private API::Node identifySshClientObject() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Find calls to set_missing_host_key_policy with unsafe arguments
from DataFlow::CallCfgNode hostKeyPolicyCall, DataFlow::Node policyArgument, string riskyPolicyName
where
  // Documentation reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  hostKeyPolicyCall = identifySshClientObject().getMember("set_missing_host_key_policy").getACall() and
  policyArgument in [hostKeyPolicyCall.getArg(0), hostKeyPolicyCall.getArgByName("policy")] and
  (
    policyArgument = retrieveInsecureHostKeyPolicy(riskyPolicyName).getAValueReachableFromSource() or
    policyArgument = retrieveInsecureHostKeyPolicy(riskyPolicyName).getReturn().getAValueReachableFromSource()
  )
select hostKeyPolicyCall, "Configuring host key policy with " + riskyPolicyName + " creates security vulnerability."