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

// Represents protocol configuration nodes in data flow analysis
class ProtocolConfiguration extends DataFlow::Node {
  ProtocolConfiguration() {
    // Context-based insecure connection creation cases
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Direct insecure connection creation cases
    unsafe_connection_creation_without_context(this, _)
    or
    // Insecure context initialization cases
    unsafe_context_creation(this, _)
  }

  // Retrieves associated function node for configuration
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

// Represents nodes identifiable with qualified names
class NameableNode extends DataFlow::Node {
  NameableNode() {
    // Function nodes from protocol configurations
    this = any(ProtocolConfiguration config).getAssociatedFunction()
    or
    // Attribute reference source nodes
    this = any(NameableNode source).(DataFlow::AttrRef).getObject()
  }
}

// Generates qualified names for nameable nodes
string getQualifiedName(NameableNode node) {
  // Direct name resolution for identifiers
  result = node.asExpr().(Name).getId()
  or
  // Composite name resolution for attributes
  exists(DataFlow::AttrRef attrNode | attrNode = node |
    result = getQualifiedName(attrNode.getObject()) + "." + attrNode.getAttributeName()
  )
}

// Generates descriptive names for protocol configurations
string getConfigurationDescription(ProtocolConfiguration config) {
  // Function call configuration description
  result = "call to " + getQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Non-call configuration description
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Maps boolean flags to descriptive verbs
string getDescriptiveVerb(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

// Main query detecting insecure protocol usage
from
  DataFlow::Node connNode, string insecureVersion, 
  ProtocolConfiguration protocolConfigNode, boolean isExplicit
where
  // Context-based insecure connection scenarios
  unsafe_connection_creation_with_context(connNode, insecureVersion, protocolConfigNode, isExplicit)
  or
  // Direct insecure connection scenarios
  unsafe_connection_creation_without_context(connNode, insecureVersion) and
  protocolConfigNode = connNode and
  isExplicit = true
  or
  // Insecure context initialization scenarios
  unsafe_context_creation(protocolConfigNode, insecureVersion) and
  connNode = protocolConfigNode and
  isExplicit = true
select connNode,
  "Insecure SSL/TLS protocol version " + insecureVersion + " " + getDescriptiveVerb(isExplicit) + 
  " by $@.", protocolConfigNode, getConfigurationDescription(protocolConfigNode)