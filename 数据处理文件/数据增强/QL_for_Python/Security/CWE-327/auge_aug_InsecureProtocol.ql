/**
 * @name Use of insecure SSL/TLS version
 * @description Detects configurations using deprecated SSL/TLS protocol versions vulnerable to attacks
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
    /* Case 1: Insecure connection with context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Insecure connection without context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Insecure context creation */
    unsafe_context_creation(this, _)
  }

  /* Retrieves the function node associated with this configuration */
  DataFlow::Node getFunctionNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* Represents nodes that can be qualified (function calls or attribute references) */
class QualifiedNode extends DataFlow::Node {
  QualifiedNode() {
    /* Case 1: Node from protocol configuration function */
    this = any(InsecureProtocolConfig cfg).getFunctionNode()
    or
    /* Case 2: Attribute reference of another qualified node */
    this = any(QualifiedNode base).(DataFlow::AttrRef).getObject()
  }
}

/* Builds qualified name for nodes with hierarchical naming */
string getQualifiedName(QualifiedNode n) {
  /* Case 1: Direct function name */
  result = n.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attr | attr = n |
    result = getQualifiedName(attr.getObject()) + "." + attr.getAttributeName()
  )
}

/* Generates descriptive label for protocol configuration */
string getConfigLabel(InsecureProtocolConfig cfg) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode call | call = cfg |
    result = "call to " + getQualifiedName(call.getFunction())
  )
  or
  /* Case 2: Non-call context modification */
  not cfg instanceof DataFlow::CallCfgNode and
  not cfg instanceof ContextCreation and
  result = "context modification"
}

/* Determines appropriate verb based on specificity flag */
string getVerb(boolean specificFlag) {
  specificFlag = true and result = "specified"
  or
  specificFlag = false and result = "allowed"
}

/* Main query detecting insecure SSL/TLS version usage */
from
  DataFlow::Node connNode, string version, 
  InsecureProtocolConfig cfgNode, boolean specificFlag
where
  /* Case 1: Insecure connection with context */
  unsafe_connection_creation_with_context(connNode, version, cfgNode, specificFlag)
  or
  /* Case 2: Insecure connection without context */
  unsafe_connection_creation_without_context(connNode, version) and
  cfgNode = connNode and
  specificFlag = true
  or
  /* Case 3: Insecure context creation */
  unsafe_context_creation(cfgNode, version) and
  connNode = cfgNode and
  specificFlag = true
select connNode,
  "Insecure SSL/TLS protocol version " + version + " " + getVerb(specificFlag) + " by $@.",
  cfgNode, getConfigLabel(cfgNode)