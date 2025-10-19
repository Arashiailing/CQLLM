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

// Identifies API nodes representing Paramiko's insecure host key policies
private API::Node getInsecureHostKeyPolicy(string policyType) {
  // Matches either AutoAddPolicy or WarningPolicy from paramiko.client or directly from paramiko module
  policyType in ["AutoAddPolicy", "WarningPolicy"] and
  (
    result = API::moduleImport("paramiko").getMember("client").getMember(policyType)
    or
    result = API::moduleImport("paramiko").getMember(policyType)
  )
}

// Retrieves API nodes representing Paramiko SSHClient instances
private API::Node getSSHClientInstance() {
  // Handles both paramiko.client.SSHClient and paramiko.SSHClient import patterns
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Checks if a given node is an argument to a set_missing_host_key_policy call
private predicate isPolicyArgument(DataFlow::CallCfgNode policyCall, DataFlow::Node policyArg) {
  exists(API::Node sshClient |
    sshClient = getSSHClientInstance() and
    policyCall = sshClient.getMember("set_missing_host_key_policy").getACall() and
    (
      policyArg = policyCall.getArg(0)
      or
      policyArg = policyCall.getArgByName("policy")
    )
  )
}

// Detects potentially unsafe host key policy configurations
from DataFlow::CallCfgNode policyCall, DataFlow::Node policyArg, string policyType
where
  isPolicyArgument(policyCall, policyArg) and
  (
    policyArg = getInsecureHostKeyPolicy(policyType).getAValueReachableFromSource()
    or
    policyArg = getInsecureHostKeyPolicy(policyType).getReturn().getAValueReachableFromSource()
  )
select policyCall, "Setting missing host key policy to " + policyType + " may be unsafe."