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
    // Cases involving context-based insecure connection creation
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Cases involving direct insecure connection creation
    unsafe_connection_creation_without_context(this, _)
    or
    // Cases involving insecure context initialization
    unsafe_context_creation(this, _)
  }

  // Retrieves the function node associated with this configuration
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

// Represents nodes that can be identified with a qualified name
class NameableNode extends DataFlow::Node {
  NameableNode() {
    // Nodes that are functions of protocol configurations
    this = any(ProtocolConfiguration config).getAssociatedFunction()
    or
    // Nodes accessed through attribute references
    this = any(NameableNode source).(DataFlow::AttrRef).getObject()
  }
}

// Generates qualified names for nameable nodes
string getQualifiedName(NameableNode node) {
  // Direct name resolution for identifier nodes
  result = node.asExpr().(Name).getId()
  or
  // Composite name resolution for attribute references
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates descriptive names for protocol configurations
string getConfigurationDescription(ProtocolConfiguration config) {
  // Description for function call configurations
  result = "call to " + getQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Description for non-call, non-context configurations
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
  DataFlow::Node connectionNode, string vulnerableVersion, 
  ProtocolConfiguration configNode, boolean isExplicit
where
  // Context-based insecure connection scenarios
  unsafe_connection_creation_with_context(connectionNode, vulnerableVersion, configNode, isExplicit)
  or
  // Direct insecure connection scenarios
  unsafe_connection_creation_without_context(connectionNode, vulnerableVersion) and
  configNode = connectionNode and
  isExplicit = true
  or
  // Insecure context initialization scenarios
  unsafe_context_creation(configNode, vulnerableVersion) and
  connectionNode = configNode and
  isExplicit = true
select connectionNode,
  "Insecure SSL/TLS protocol version " + vulnerableVersion + " " + getDescriptiveVerb(isExplicit) + 
  " by $@.", configNode, getConfigurationDescription(configNode)