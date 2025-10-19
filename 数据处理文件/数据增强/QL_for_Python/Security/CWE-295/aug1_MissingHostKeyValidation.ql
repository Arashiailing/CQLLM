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

// Identify unsafe Paramiko policy classes that accept unknown host keys
private API::Node getUnsafePolicyNode(string policyName) {
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Obtain Paramiko SSHClient instance references
private API::Node getSshClientInstance() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detect unsafe host key policy configurations
from DataFlow::CallCfgNode methodCall, DataFlow::Node policyArg, string policyName
where
  // Reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  methodCall = getSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  policyArg in [methodCall.getArg(0), methodCall.getArgByName("policy")] and
  (
    policyArg = getUnsafePolicyNode(policyName).getAValueReachableFromSource() or
    policyArg = getUnsafePolicyNode(policyName).getReturn().getAValueReachableFromSource()
  )
select methodCall, "Setting missing host key policy to " + policyName + " may be unsafe."