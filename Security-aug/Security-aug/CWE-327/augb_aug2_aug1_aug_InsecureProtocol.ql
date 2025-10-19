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

/* Represents nodes that configure potentially insecure SSL/TLS protocol versions */
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    /* Case 1: Creating insecure connection with context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Creating insecure connection without context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Creating insecure context */
    unsafe_context_creation(this, _)
  }

  /* Retrieves the function node associated with this configuration */
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

/* Represents nodes that can be named (function calls or attribute references) */
class IdentifiableNode extends DataFlow::Node {
  IdentifiableNode() {
    /* Case 1: Node is a function from a protocol configuration */
    this = any(InsecureProtocolConfig ipc).getAssociatedFunction()
    or
    /* Case 2: Node is an attribute reference of another identifiable node */
    this = any(IdentifiableNode attr).(DataFlow::AttrRef).getObject()
  }
}

/* Retrieves the fully qualified name of an identifiable node */
string getFullyQualifiedName(IdentifiableNode node) {
  /* Case 1: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attrRef | 
    attrRef = node and
    result = getFullyQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/* Retrieves a descriptive name for the protocol configuration */
string getConfigDescription(InsecureProtocolConfig configNode) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode call | 
    call = configNode and
    result = "call to " + getFullyQualifiedName(call.getFunction())
  )
  or
  /* Case 2: Context modification (non-call, non-context creation) */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* Retrieves the appropriate verb based on specificity flag */
string getAppropriateVerb(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

/* Query to detect usage of insecure SSL/TLS protocol versions */
from
  DataFlow::Node vulnerableNode, string protocolVersion, 
  InsecureProtocolConfig configNode, boolean isExplicit
where
  /* Case 1: Insecure connection with context */
  (
    unsafe_connection_creation_with_context(vulnerableNode, protocolVersion, configNode, isExplicit)
  )
  or
  /* Case 2: Insecure connection without context */
  (
    unsafe_connection_creation_without_context(vulnerableNode, protocolVersion) and
    configNode = vulnerableNode and
    isExplicit = true
  )
  or
  /* Case 3: Insecure context creation */
  (
    unsafe_context_creation(configNode, protocolVersion) and
    vulnerableNode = configNode and
    isExplicit = true
  )
select vulnerableNode,
  "Insecure SSL/TLS protocol version " + protocolVersion + " " + getAppropriateVerb(isExplicit) + " by $@.",
  configNode, getConfigDescription(configNode)