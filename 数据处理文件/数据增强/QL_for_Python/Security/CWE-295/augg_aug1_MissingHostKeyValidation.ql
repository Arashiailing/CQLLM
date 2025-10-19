/**
 * @name Accepting unknown SSH host keys when using Paramiko
 * @description Detects configurations where Paramiko accepts unknown host keys,
 *              which could enable man-in-the-middle attacks.
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
private API::Node getInsecurePolicyNode(string policyName) {
  policyName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

// Obtain Paramiko SSHClient instance references
private API::Node getSshClientConstructor() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detect unsafe host key policy configurations
from DataFlow::CallCfgNode cfgNode, DataFlow::Node policyArgument, string insecurePolicyName
where
  // Reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  cfgNode = getSshClientConstructor().getMember("set_missing_host_key_policy").getACall() and
  (
    policyArgument = cfgNode.getArg(0) 
    or 
    policyArgument = cfgNode.getArgByName("policy")
  ) and
  insecurePolicyName = "AutoAddPolicy" or insecurePolicyName = "WarningPolicy" and
  (
    policyArgument = getInsecurePolicyNode(insecurePolicyName).getAValueReachableFromSource()
    or
    policyArgument = getInsecurePolicyNode(insecurePolicyName).getReturn().getAValueReachableFromSource()
  )
select cfgNode, "Setting missing host key policy to " + insecurePolicyName + " may be unsafe."