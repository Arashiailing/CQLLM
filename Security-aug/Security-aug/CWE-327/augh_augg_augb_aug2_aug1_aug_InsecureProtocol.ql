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

/* Represents configuration nodes enabling deprecated SSL/TLS protocol versions */
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    /* Case 1: Contextual insecure connections */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Non-contextual insecure connections */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Insecure context initialization */
    unsafe_context_creation(this, _)
  }

  /* Retrieves the associated function for this configuration */
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

/* Represents nodes with identifiable names (function calls or attribute references) */
class IdentifiableNode extends DataFlow::Node {
  IdentifiableNode() {
    /* Case 1: Protocol configuration functions */
    this = any(InsecureProtocolConfig ipc).getAssociatedFunction()
    or
    /* Case 2: Attribute reference chains */
    this = any(IdentifiableNode attr).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs fully qualified names for identifiable nodes */
string getFullyQualifiedName(IdentifiableNode node) {
  /* Case 1: Attribute access path construction */
  exists(DataFlow::AttrRef attrRefNode | 
    attrRefNode = node and
    result = getFullyQualifiedName(attrRefNode.getObject()) + "." + attrRefNode.getAttributeName()
  )
  or
  /* Case 2: Direct function name retrieval */
  result = node.asExpr().(Name).getId()
}

/* Generates descriptive labels for protocol configurations */
string getConfigDescription(InsecureProtocolConfig configNode) {
  /* Case 1: Non-call context modifications */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
  or
  /* Case 2: Function call configurations */
  exists(DataFlow::CallCfgNode callNode | 
    callNode = configNode and
    result = "call to " + getFullyQualifiedName(callNode.getFunction())
  )
}

/* Selects appropriate verb based on configuration specificity */
string getAppropriateVerb(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

/* Main query: Detects insecure SSL/TLS protocol usage */
from
  DataFlow::Node vulnNode, string protoVer, 
  InsecureProtocolConfig cfgNode, boolean explicitFlag
where
  /* Case 1: Contextual insecure connections */
  unsafe_connection_creation_with_context(vulnNode, protoVer, cfgNode, explicitFlag)
  or
  /* Case 2: Non-contextual insecure connections */
  (
    unsafe_connection_creation_without_context(vulnNode, protoVer) and
    cfgNode = vulnNode and
    explicitFlag = true
  )
  or
  /* Case 3: Insecure context initialization */
  (
    unsafe_context_creation(cfgNode, protoVer) and
    vulnNode = cfgNode and
    explicitFlag = true
  )
select vulnNode,
  "Insecure SSL/TLS protocol version " + protoVer + " " + getAppropriateVerb(explicitFlag) + " by $@.",
  cfgNode, getConfigDescription(cfgNode)