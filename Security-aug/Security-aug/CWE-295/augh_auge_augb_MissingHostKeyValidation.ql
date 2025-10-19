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
private API::Node getInsecureParamikoPolicy(string insecurePolicyTypeName) {
  // Matches insecure policy types from paramiko.client or paramiko module
  insecurePolicyTypeName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(insecurePolicyTypeName)
    or
    result = API::moduleImport("paramiko").getMember(insecurePolicyTypeName)
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
from DataFlow::CallCfgNode policySettingCall, DataFlow::Node policyArg, string policyName
where
  // Locates set_missing_host_key_policy method calls on SSHClient instances
  policySettingCall = getParamikoSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  
  // Identifies policy arguments passed via position or keyword
  policyArg in [policySettingCall.getArg(0), policySettingCall.getArgByName("policy")] and
  
  // Verifies argument references an insecure policy implementation
  (
    policyArg = getInsecureParamikoPolicy(policyName).getAValueReachableFromSource() 
    or 
    policyArg = getInsecureParamikoPolicy(policyName).getReturn().getAValueReachableFromSource()
  )
select policySettingCall, "Configuring host key policy to " + policyName + " creates security vulnerability."