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
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* Represents nodes that can be named (function calls or attribute references) */
class NamedNode extends DataFlow::Node {
  NamedNode() {
    /* Case 1: Node is a function in protocol configuration */
    this = any(InsecureProtocolConfig ipc).getAssociatedFunction()
    or
    /* Case 2: Node is an attribute reference of another named node */
    this = any(NamedNode attr).(DataFlow::AttrRef).getObject()
  }
}

/* Retrieves the fully qualified name of a named node */
string getFullyQualifiedName(NamedNode node) {
  /* Case 1: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getFullyQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/* Retrieves descriptive name for protocol configuration */
string getProtocolConfigDescription(InsecureProtocolConfig configNode) {
  /* Case 1: Function call configuration */
  result = "call to " + getFullyQualifiedName(configNode.(DataFlow::CallCfgNode).getFunction())
  or
  /* Case 2: Context modification (non-call, non-context creation) */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* Retrieves appropriate verb based on specificity flag */
string getSpecificityVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

/* Query detecting insecure SSL/TLS version usage */
from
  DataFlow::Node insecureConnNode, string insecureProtoVer, 
  InsecureProtocolConfig protoConfigNode, boolean isSpecificVer
where
  /* Case 1: Insecure connection creation with context */
  (
    unsafe_connection_creation_with_context(insecureConnNode, insecureProtoVer, protoConfigNode, isSpecificVer)
  )
  or
  /* Case 2: Insecure connection creation without context */
  (
    unsafe_connection_creation_without_context(insecureConnNode, insecureProtoVer) and
    protoConfigNode = insecureConnNode and
    isSpecificVer = true
  )
  or
  /* Case 3: Insecure context creation */
  (
    unsafe_context_creation(protoConfigNode, insecureProtoVer) and
    insecureConnNode = protoConfigNode and
    isSpecificVer = true
  )
select insecureConnNode,
  "Insecure SSL/TLS protocol version " + insecureProtoVer + " " + getSpecificityVerb(isSpecificVer) + " by $@.",
  protoConfigNode, getProtocolConfigDescription(protoConfigNode)