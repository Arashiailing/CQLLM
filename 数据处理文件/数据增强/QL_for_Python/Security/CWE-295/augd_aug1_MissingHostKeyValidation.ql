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

/**
 * Identifies Paramiko policy classes that accept unknown host keys
 * @param policyName The name of the insecure policy (e.g. "AutoAddPolicy")
 * @returns API node representing the insecure policy
 */
private API::Node getInsecurePolicyNode(string policyName) {
  policyName = "AutoAddPolicy" or policyName = "WarningPolicy" and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyName)
    or
    result = API::moduleImport("paramiko").getMember(policyName)
  )
}

/**
 * Obtains references to Paramiko SSHClient instances
 * @returns API node representing SSHClient instances
 */
private API::Node getSshClientRef() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detects unsafe host key policy configurations
from DataFlow::CallCfgNode policySettingCall, DataFlow::Node policyArgument, string policyName
where
  // Reference: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  policySettingCall = getSshClientRef().getMember("set_missing_host_key_policy").getACall() and
  policyArgument in [policySettingCall.getArg(0), policySettingCall.getArgByName("policy")] and
  (
    policyArgument = getInsecurePolicyNode(policyName).getAValueReachableFromSource() 
    or
    policyArgument = getInsecurePolicyNode(policyName).getReturn().getAValueReachableFromSource()
  )
select policySettingCall, "Setting missing host key policy to " + policyName + " may be unsafe."