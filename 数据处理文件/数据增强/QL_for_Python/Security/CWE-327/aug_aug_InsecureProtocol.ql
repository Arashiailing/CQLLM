/**
 * @name Use of insecure SSL/TLS version
 * @description Detects when insecure SSL/TLS protocol versions are used, potentially exposing connections to attacks.
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
    /* Case 1: Insecure connection created with context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Insecure connection created without context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Insecure context creation */
    unsafe_context_creation(this, _)
  }

  /* Get the function node associated with this configuration */
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* Represents nodes that can be named (function calls or attribute references) */
class QualifiedNode extends DataFlow::Node {
  QualifiedNode() {
    /* Case 1: Node is a function from a protocol configuration */
    this = any(InsecureProtocolConfig ipc).getAssociatedFunction()
    or
    /* Case 2: Node is an attribute reference of another qualified node */
    this = any(QualifiedNode qn).(DataFlow::AttrRef).getObject()
  }
}

/* Get the qualified name of a qualified node */
string getNodeQualifiedName(QualifiedNode node) {
  /* Case 1: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getNodeQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/* Get descriptive name for protocol configuration */
string getConfigNodeDescription(InsecureProtocolConfig configNode) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode callNode | callNode = configNode |
    result = "call to " + getNodeQualifiedName(callNode.getFunction())
  )
  or
  /* Case 2: Context modification (non-call, non-context-creation) */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* Get appropriate verb based on specificity flag */
string getVerbForm(boolean specificityFlag) {
  specificityFlag = true and result = "specified"
  or
  specificityFlag = false and result = "allowed"
}

/* Query to detect insecure SSL/TLS version usage */
from
  DataFlow::Node insecureConnectionNode, string insecureVersion, 
  InsecureProtocolConfig configNode, boolean specificityFlag
where
  /* Case 1: Insecure connection with context */
  (
    unsafe_connection_creation_with_context(insecureConnectionNode, insecureVersion, configNode, specificityFlag)
  )
  or
  /* Case 2: Insecure connection without context */
  (
    unsafe_connection_creation_without_context(insecureConnectionNode, insecureVersion) and
    configNode = insecureConnectionNode and
    specificityFlag = true
  )
  or
  /* Case 3: Insecure context creation */
  (
    unsafe_context_creation(configNode, insecureVersion) and
    insecureConnectionNode = configNode and
    specificityFlag = true
  )
select insecureConnectionNode,
  "Insecure SSL/TLS protocol version " + insecureVersion + " " + getVerbForm(specificityFlag) + " by $@.",
  configNode, getConfigNodeDescription(configNode)