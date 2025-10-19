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
    this = any(NamedNode parent).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs fully qualified name for named nodes */
string getFullQualifiedName(NamedNode node) {
  /* Case 1: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access path */
  exists(DataFlow::AttrRef attr | attr = node |
    result = getFullQualifiedName(attr.getObject()) + "." + attr.getAttributeName()
  )
}

/* Generates descriptive label for protocol configuration */
string getConfigDescription(InsecureProtocolConfig config) {
  /* Case 1: Function call configuration */
  result = "call to " + getFullQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  /* Case 2: Context configuration (non-call) */
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

/* Determines action verb based on specificity flag */
string getActionVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

/* Main query detecting insecure protocol usage */
from
  DataFlow::Node connNode, string vulnVersion, 
  InsecureProtocolConfig config, boolean isSpecific
where
  (
    /* Case 1: Insecure connection with context */
    unsafe_connection_creation_with_context(connNode, vulnVersion, config, isSpecific)
  )
  or
  (
    /* Case 2: Direct insecure connection */
    unsafe_connection_creation_without_context(connNode, vulnVersion) and
    config = connNode and
    isSpecific = true
  )
  or
  (
    /* Case 3: Insecure context creation */
    unsafe_context_creation(config, vulnVersion) and
    connNode = config and
    isSpecific = true
  )
select connNode,
  "Insecure SSL/TLS protocol version " + vulnVersion + " " + getActionVerb(isSpecific) + " by $@.",
  config, getConfigDescription(config)