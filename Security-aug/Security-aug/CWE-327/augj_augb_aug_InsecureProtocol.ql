/**
 * @name Use of insecure SSL/TLS version
 * @description Detects usage of deprecated SSL/TLS protocol versions vulnerable to attacks
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

/* Represents protocol configuration nodes using insecure SSL/TLS versions */
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    /* Case 1: Connection established with insecure context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Direct insecure connection without context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Insecure security context created */
    unsafe_context_creation(this, _)
  }

  /* Retrieves associated function node for this configuration */
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* Represents nodes with identifiable names (functions or attributes) */
class NamedNode extends DataFlow::Node {
  NamedNode() {
    /* Case 1: Function from protocol configuration */
    this = any(InsecureProtocolConfig ipc).getAssociatedFunction()
    or
    /* Case 2: Attribute reference chain */
    this = any(NamedNode baseNode).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs fully qualified name for named nodes */
string getFullQualifiedName(NamedNode currentNode) {
  /* Case 1: Attribute access path */
  exists(DataFlow::AttrRef attrRef | attrRef = currentNode |
    result = getFullQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
  or
  /* Case 2: Direct function name */
  result = currentNode.asExpr().(Name).getId()
}

/* Generates descriptive label for protocol configuration */
string getConfigDescription(InsecureProtocolConfig protocolConfig) {
  /* Case 1: Context configuration (non-call) */
  not protocolConfig instanceof DataFlow::CallCfgNode and
  not protocolConfig instanceof ContextCreation and
  result = "context modification"
  or
  /* Case 2: Function call configuration */
  result = "call to " + getFullQualifiedName(protocolConfig.(DataFlow::CallCfgNode).getFunction())
}

/* Determines action verb based on specificity flag */
string getActionVerb(boolean specificFlag) {
  specificFlag = true and result = "specified"
  or
  specificFlag = false and result = "allowed"
}

/* Main query detecting insecure protocol usage */
from
  DataFlow::Node connectionNode, string vulnerableVersion, 
  InsecureProtocolConfig protocolConfig, boolean specificFlag
where
  (
    /* Case 1: Insecure connection with context */
    unsafe_connection_creation_with_context(connectionNode, vulnerableVersion, protocolConfig, specificFlag)
  )
  or
  (
    /* Case 2: Direct insecure connection */
    unsafe_connection_creation_without_context(connectionNode, vulnerableVersion) and
    protocolConfig = connectionNode and
    specificFlag = true
  )
  or
  (
    /* Case 3: Insecure context creation */
    unsafe_context_creation(protocolConfig, vulnerableVersion) and
    connectionNode = protocolConfig and
    specificFlag = true
  )
select connectionNode,
  "Insecure SSL/TLS protocol version " + vulnerableVersion + " " + getActionVerb(specificFlag) + " by $@.",
  protocolConfig, getConfigDescription(protocolConfig)