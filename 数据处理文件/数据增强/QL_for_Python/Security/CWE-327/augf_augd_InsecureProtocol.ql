/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies code utilizing deprecated SSL/TLS protocol versions that are susceptible to security vulnerabilities.
 * @id py/insecure-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

import python
import semmle.python.dataflow.new.DataFlow
import FluentApiModel

// Represents nodes that configure insecure protocol settings
class InsecureProtocolConfiguration extends DataFlow::Node {
  InsecureProtocolConfiguration() {
    // Detects connections established with security context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Detects connections established without security context
    unsafe_connection_creation_without_context(this, _)
    or
    // Detects direct creation of insecure security contexts
    unsafe_context_creation(this, _)
  }

  // Retrieves the associated function node
  DataFlow::Node getFunctionNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

// Represents nodes that can have qualified names (functions or attribute accesses)
class QualifiedNode extends DataFlow::Node {
  QualifiedNode() {
    // Matches function nodes from protocol configurations
    this = any(InsecureProtocolConfiguration cfg).getFunctionNode()
    or
    // Matches attribute access objects
    this = any(QualifiedNode attr).(DataFlow::AttrRef).getObject()
  }
}

// Builds qualified names for callable nodes by traversing attribute chains
string buildQualifiedName(QualifiedNode node) {
  // Base case: direct function name
  result = node.asExpr().(Name).getId()
  or
  // Recursive case: attribute access chains
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = buildQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates human-readable descriptions for protocol configurations
string generateConfigDescription(InsecureProtocolConfiguration config) {
  // Case 1: Configuration via function call
  result = "call to " + buildQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Case 2: Configuration via context modification (non-callable)
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Determines appropriate verb based on configuration specificity
string determineVerb(boolean isSpecificConfiguration) {
  isSpecificConfiguration = true and result = "specified"
  or
  isSpecificConfiguration = false and result = "allowed"
}

// Main query logic to detect insecure protocol usage
from
  DataFlow::Node insecureConnectionNode, string insecureProtocolVersion, 
  InsecureProtocolConfiguration protocolConfiguration, boolean isSpecificConfiguration
where
  // Scenario 1: Insecure connection created with security context
  unsafe_connection_creation_with_context(insecureConnectionNode, insecureProtocolVersion, protocolConfiguration, isSpecificConfiguration)
  or
  // Scenario 2: Insecure connection created without security context
  unsafe_connection_creation_without_context(insecureConnectionNode, insecureProtocolVersion) and
  protocolConfiguration = insecureConnectionNode and
  isSpecificConfiguration = true
  or
  // Scenario 3: Insecure security context created directly
  unsafe_context_creation(protocolConfiguration, insecureProtocolVersion) and
  insecureConnectionNode = protocolConfiguration and
  isSpecificConfiguration = true
select insecureConnectionNode,
  "Insecure SSL/TLS protocol version " + insecureProtocolVersion + " " + determineVerb(isSpecificConfiguration) + " by $@.",
  protocolConfiguration, generateConfigDescription(protocolConfiguration)