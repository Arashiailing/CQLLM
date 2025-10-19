/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies deprecated SSL/TLS protocol versions that may expose connections to security vulnerabilities.
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

/* Represents configuration nodes enabling insecure SSL/TLS protocol versions */
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    /* Case 1: Insecure connections with context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Insecure connections without context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Insecure context creation */
    unsafe_context_creation(this, _)
  }

  /* Retrieves the function associated with this configuration */
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

/* Represents nodes that can be named (function calls or attribute references) */
class IdentifiableNode extends DataFlow::Node {
  IdentifiableNode() {
    /* Case 1: Function from protocol configuration */
    this = any(InsecureProtocolConfig insecureConfig).getAssociatedFunction()
    or
    /* Case 2: Attribute reference chain */
    this = any(IdentifiableNode attrNode).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs fully qualified name for identifiable nodes */
string getFullyQualifiedName(IdentifiableNode node) {
  /* Case 1: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access path */
  exists(DataFlow::AttrRef attrRefNode | 
    attrRefNode = node and
    result = getFullyQualifiedName(attrRefNode.getObject()) + "." + attrRefNode.getAttributeName()
  )
}

/* Generates descriptive label for protocol configuration */
string getConfigDescription(InsecureProtocolConfig configNode) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode callNode | 
    callNode = configNode and
    result = "call to " + getFullyQualifiedName(callNode.getFunction())
  )
  or
  /* Case 2: Non-call context modification */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* Selects appropriate verb based on configuration specificity */
string getAppropriateVerb(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

/* Main query: Detects insecure SSL/TLS protocol usage */
from
  DataFlow::Node vulnerableNode, string protocolVersion, 
  InsecureProtocolConfig configNode, boolean isExplicit
where
  /* Case 1: Insecure connection with context */
  unsafe_connection_creation_with_context(vulnerableNode, protocolVersion, configNode, isExplicit)
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