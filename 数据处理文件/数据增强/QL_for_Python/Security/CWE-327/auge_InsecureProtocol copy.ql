/**
 * @name Use of insecure SSL/TLS version
 * @description Using an insecure SSL/TLS version may leave the connection vulnerable to attacks.
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

// Represents protocol configuration nodes in data flow
class ProtocolConfigNode extends DataFlow::Node {
  ProtocolConfigNode() {
    // Case 1: Unsafe connection with context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Case 2: Unsafe connection without context
    unsafe_connection_creation_without_context(this, _)
    or
    // Case 3: Unsafe context creation
    unsafe_context_creation(this, _)
  }

  // Get the associated function node
  DataFlow::Node getFunctionNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

// Represents nodes that can be named (functions or attributes)
class NameableNode extends DataFlow::Node {
  NameableNode() {
    // Function node from protocol configuration
    this = any(ProtocolConfigNode pc).getFunctionNode()
    or
    // Attribute reference on nameable objects
    this = any(NameableNode attr).(DataFlow::AttrRef).getObject()
  }
}

// Get the qualified name of a nameable node
string getNodeName(NameableNode node) {
  // Direct name for simple nodes
  result = node.asExpr().(Name).getId()
  or
  // Composed name for attribute references
  exists(DataFlow::AttrRef attr | attr = node |
    result = getNodeName(attr.getObject()) + "." + attr.getAttributeName()
  )
}

// Get descriptive name for protocol configuration
string getConfigDescription(ProtocolConfigNode config) {
  // Call-based configuration
  exists(DataFlow::CallCfgNode call | call = config |
    result = "call to " + getNodeName(call.getFunction())
  )
  or
  // Non-call configuration
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Get verb based on configuration specificity
string getVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

// Main query detecting insecure protocol usage
from
  DataFlow::Node connNode, string version, ProtocolConfigNode configNode,
  boolean isSpecific
where
  // Case 1: Context-based insecure connection
  unsafe_connection_creation_with_context(connNode, version, configNode, isSpecific)
  or
  // Case 2: Direct insecure connection
  unsafe_connection_creation_without_context(connNode, version) and
  configNode = connNode and
  isSpecific = true
  or
  // Case 3: Insecure context creation
  unsafe_context_creation(configNode, version) and
  connNode = configNode and
  isSpecific = true
select connNode,
  "Insecure SSL/TLS protocol version " + version + " " + getVerb(isSpecific) + " by $@.",
  configNode, getConfigDescription(configNode)