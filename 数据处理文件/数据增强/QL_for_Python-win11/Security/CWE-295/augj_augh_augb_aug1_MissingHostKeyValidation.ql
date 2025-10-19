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
// These policies are considered insecure as they don't properly verify host identities
private API::Node retrieveInsecureHostKeyPolicy(string policyTypeName) {
  // Check for known insecure policy types
  policyTypeName in ["AutoAddPolicy", "WarningPolicy"] and
  (
    // Handle both import paths: paramiko.client.PolicyName and paramiko.PolicyName
    result = API::moduleImport("paramiko").getMember("client").getMember(policyTypeName)
    or
    result = API::moduleImport("paramiko").getMember(policyTypeName)
  )
}

// Identify Paramiko SSHClient class instances that can be configured with host key policies
// This covers both direct and indirect import paths for the SSHClient class
private API::Node fetchSshClientInstance() {
  result = API::moduleImport("paramiko").getMember("client").getMember("SSHClient").getReturn()
  or
  result = API::moduleImport("paramiko").getMember("SSHClient").getReturn()
}

// Detect unsafe host key policy configurations in SSH client usage
from DataFlow::CallCfgNode hostKeyPolicyCall, DataFlow::Node policyParameter, string policyIdentifier
where
  // Identify calls to set_missing_host_key_policy method on SSHClient instances
  // Documentation: http://docs.paramiko.org/en/stable/api/client.html#paramiko.client.SSHClient.set_missing_host_key_policy
  hostKeyPolicyCall = fetchSshClientInstance().getMember("set_missing_host_key_policy").getACall() and
  
  // Extract the policy argument from the method call (either positional or named parameter)
  policyParameter in [hostKeyPolicyCall.getArg(0), hostKeyPolicyCall.getArgByName("policy")] and
  
  // Verify that the policy argument corresponds to an insecure policy implementation
  (
    policyParameter = retrieveInsecureHostKeyPolicy(policyIdentifier).getAValueReachableFromSource() or
    policyParameter = retrieveInsecureHostKeyPolicy(policyIdentifier).getReturn().getAValueReachableFromSource()
  )
select hostKeyPolicyCall, "Configuring host key policy with " + policyIdentifier + " creates security vulnerability."