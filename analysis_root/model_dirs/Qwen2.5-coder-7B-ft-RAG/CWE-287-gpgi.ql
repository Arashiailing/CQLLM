/**
 * @name PAM authorization flow analysis
 * @description This query analyzes the flow of user-provided values through the pam_authenticate call in Python programs,
 *             identifying where these values could be tampered with before reaching pam_acct_mgmt, which is crucial for
 *             proper authentication verification.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/pam-auth-flow
 * @tags security
 *       external/cwe/cwe-285
 */

// Import core Python language support
import python

// Import specialized modules for analyzing PAM authorization flows
import PamAuthorizationFlow::PathGraph

// Define primary components of the data flow analysis
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery

// Identify key nodes in the data flow path
from PamAuthorizationFlow::PathNode sourceNode, PamAuthorizationFlow::PathNode destinationNode

// Establish conditions for complete data flow paths
where PamAuthorizationFlow::flowPath(sourceNode, destinationNode)

// Generate detailed results with contextual information
select destinationNode.getNode(), sourceNode, destinationNode,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  sourceNode.getNode(), "user-provided value"