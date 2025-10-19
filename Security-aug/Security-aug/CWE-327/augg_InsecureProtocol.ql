/**
 * @name Use of insecure SSL/TLS version
 * @description Detects usage of deprecated SSL/TLS protocol versions vulnerable to attacks.
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
    // Case 1: Insecure connection with context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Case 2: Insecure connection without context
    unsafe_connection_creation_without_context(this, _)
    or
    // Case 3: Insecure context creation
    unsafe_context_creation(this, _)
  }

  // Retrieves the function node associated with this configuration
  DataFlow::Node getFunctionNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

// Represents nodes that can be assigned meaningful names
class NameableNode extends DataFlow::Node {
  NameableNode() {
    // Case 1: Node is a function from protocol configuration
    this = any(ProtocolConfiguration config).getFunctionNode()
    or
    // Case 2: Node is an attribute reference of another nameable node
    this = any(NameableNode parent).(DataFlow::AttrRef).getObject()
  }
}

// Generates the qualified name for a nameable node
string getQualifiedName(NameableNode node) {
  // Base case: Simple identifier
  result = node.asExpr().(Name).getId()
  or
  // Recursive case: Attribute access
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates a descriptive name for protocol configurations
string getConfigurationName(ProtocolConfiguration config) {
  // Case 1: Function call configuration
  config instanceof DataFlow::CallCfgNode and
  result = "call to " + getQualifiedName(config.getFunctionNode())
  or
  // Case 2: Non-call configuration (context modification)
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Maps boolean flag to appropriate verb
string getVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

// Main query detecting insecure protocol usage
from
  DataFlow::Node connCreation, string insecureVersion, 
  ProtocolConfiguration protocolConfig, boolean isSpecific
where
  // Scenario 1: Context-based insecure connection
  unsafe_connection_creation_with_context(connCreation, insecureVersion, protocolConfig, isSpecific)
  or
  // Scenario 2: Direct insecure connection
  unsafe_connection_creation_without_context(connCreation, insecureVersion) and
  protocolConfig = connCreation and
  isSpecific = true
  or
  // Scenario 3: Insecure context creation
  unsafe_context_creation(protocolConfig, insecureVersion) and
  connCreation = protocolConfig and
  isSpecific = true
select connCreation,
  "Insecure SSL/TLS protocol version " + insecureVersion + " " + getVerb(isSpecific) + " by $@.",
  protocolConfig, getConfigurationName(protocolConfig)