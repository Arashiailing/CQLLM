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

/* Represents protocol configuration nodes that may use insecure SSL/TLS versions */
class ProtocolConfiguration extends DataFlow::Node {
  ProtocolConfiguration() {
    /* Case 1: Insecure connection created with context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Insecure connection created without context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Insecure context created */
    unsafe_context_creation(this, _)
  }

  /* Get the function node associated with this configuration */
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* Represents nodes that can be named (function calls or attribute references) */
class NameableNode extends DataFlow::Node {
  NameableNode() {
    /* Case 1: Node is a function from a protocol configuration */
    this = any(ProtocolConfiguration pc).getAssociatedFunction()
    or
    /* Case 2: Node is an attribute reference of another nameable node */
    this = any(NameableNode attr).(DataFlow::AttrRef).getObject()
  }
}

/* Get the qualified name of a nameable node */
string getQualifiedName(NameableNode node) {
  /* Case 1: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/* Get descriptive name for protocol configuration */
string getConfigurationName(ProtocolConfiguration configNode) {
  /* Case 1: Function call configuration */
  result = "call to " + getQualifiedName(configNode.(DataFlow::CallCfgNode).getFunction())
  or
  /* Case 2: Context modification (non-call, non-context-creation) */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* Get appropriate verb based on specificity flag */
string getVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

/* Query to detect insecure SSL/TLS version usage */
from
  DataFlow::Node connectionNode, string insecureVersion, 
  ProtocolConfiguration configNode, boolean isSpecific
where
  /* Case 1: Insecure connection with context */
  unsafe_connection_creation_with_context(connectionNode, insecureVersion, configNode, isSpecific)
  or
  /* Case 2: Insecure connection without context */
  unsafe_connection_creation_without_context(connectionNode, insecureVersion) and
  configNode = connectionNode and
  isSpecific = true
  or
  /* Case 3: Insecure context creation */
  unsafe_context_creation(configNode, insecureVersion) and
  connectionNode = configNode and
  isSpecific = true
select connectionNode,
  "Insecure SSL/TLS protocol version " + insecureVersion + " " + getVerb(isSpecific) + " by $@.",
  configNode, getConfigurationName(configNode)