/**
 * @name Use of insecure SSL/TLS version
 * @description Detects usage of deprecated SSL/TLS protocol versions that may expose connections to security vulnerabilities.
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

// Represents nodes involved in insecure protocol configuration
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    // Matches nodes from context-based insecure connection creation
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Matches nodes from direct insecure connection creation
    unsafe_connection_creation_without_context(this, _)
    or
    // Matches nodes from insecure context initialization
    unsafe_context_creation(this, _)
  }

  // Retrieves the associated function node for this configuration
  DataFlow::Node getFunctionNode() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

// Represents nodes that can be resolved to qualified names
class ResolvableNode extends DataFlow::Node {
  ResolvableNode() {
    // Nodes from protocol configuration functions
    this = any(InsecureProtocolConfig config).getFunctionNode()
    or
    // Nodes accessed through attribute references
    this = any(ResolvableNode source).(DataFlow::AttrRef).getObject()
  }
}

// Generates fully qualified names for resolvable nodes
string getFullyQualifiedName(ResolvableNode node) {
  // Handles direct name resolution for identifiers
  result = node.asExpr().(Name).getId()
  or
  // Handles composite name resolution for attribute references
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getFullyQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates human-readable descriptions for protocol configurations
string getConfigDescription(InsecureProtocolConfig config) {
  // Description for function call configurations
  result = "call to " + getFullyQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Description for non-call, non-context configurations
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Maps boolean flags to descriptive verbs for explicitness
string getVerbForExplicitness(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

// Main query detecting insecure protocol usage
from
  DataFlow::Node connNode, string vulnerableVersion, 
  InsecureProtocolConfig config, boolean isExplicit
where
  // Handles context-based insecure connection scenarios
  unsafe_connection_creation_with_context(connNode, vulnerableVersion, config, isExplicit)
  or
  // Handles direct insecure connection scenarios
  unsafe_connection_creation_without_context(connNode, vulnerableVersion) and
  config = connNode and
  isExplicit = true
  or
  // Handles insecure context initialization scenarios
  unsafe_context_creation(config, vulnerableVersion) and
  connNode = config and
  isExplicit = true
select connNode,
  "Insecure SSL/TLS protocol version " + vulnerableVersion + " " + getVerbForExplicitness(isExplicit) + 
  " by $@.", config, getConfigDescription(config)