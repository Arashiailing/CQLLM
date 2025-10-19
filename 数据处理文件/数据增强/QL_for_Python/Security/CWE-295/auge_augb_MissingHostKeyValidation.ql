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

// Retrieves Paramiko policy nodes that implement insecure host key validation
private API::Node getInsecureParamikoPolicy(string policyType) {
  // Matches insecure policy types from paramiko.client or paramiko module
  policyType in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyType)
    or
    result = API::moduleImport("paramiko").getMember(policyType)
  )
}

// Identifies Paramiko SSHClient instance creation nodes
private API::Node getParamikoSshClientInstance() {
  // Captures SSHClient instantiations from both paramiko.client and paramiko modules
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects vulnerable host key policy configurations in SSH client initialization
from DataFlow::CallCfgNode policyConfigCall, DataFlow::Node policyArgument, string insecurePolicyName
where
  // Locates set_missing_host_key_policy method calls on SSHClient instances
  policyConfigCall = getParamikoSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  // Identifies policy arguments passed via position or keyword
  policyArgument in [policyConfigCall.getArg(0), policyConfigCall.getArgByName("policy")] and
  // Verifies argument references an insecure policy implementation
  (
    policyArgument = getInsecureParamikoPolicy(insecurePolicyName).getAValueReachableFromSource() or
    policyArgument = getInsecureParamikoPolicy(insecurePolicyName).getReturn().getAValueReachableFromSource()
  )
select policyConfigCall, "Configuring host key policy to " + insecurePolicyName + " creates security vulnerability."