/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies usage of deprecated SSL/TLS protocol versions that may expose connections to security vulnerabilities.
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

/* Represents configuration nodes utilizing insecure SSL/TLS protocol versions */
class InsecureProtocolConfiguration extends DataFlow::Node {
  InsecureProtocolConfiguration() {
    /* Scenario 1: Context-based insecure connection creation */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Scenario 2: Context-free insecure connection creation */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Scenario 3: Insecure security context initialization */
    unsafe_context_creation(this, _)
  }

  /* Retrieves the function associated with this configuration */
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* Represents nodes with hierarchical naming capabilities (function calls/attribute references) */
class HierarchicalNamedNode extends DataFlow::Node {
  HierarchicalNamedNode() {
    /* Case 1: Function from protocol configuration */
    this = any(InsecureProtocolConfiguration ipc).getAssociatedFunction()
    or
    /* Case 2: Attribute reference of another named node */
    this = any(HierarchicalNamedNode hnn).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs fully qualified name for hierarchical nodes */
string getQualifiedName(HierarchicalNamedNode node) {
  /* Base case: Direct function name */
  result = node.asExpr().(Name).getId()
  or
  /* Recursive case: Attribute access chain */
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/* Generates descriptive label for protocol configuration */
string getConfigurationDescription(InsecureProtocolConfiguration config) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode call | call = config |
    result = "call to " + getQualifiedName(call.getFunction())
  )
  or
  /* Case 2: Context modification (non-call, non-creation) */
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

/* Determines appropriate verb based on configuration specificity */
string getSpecificityVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

/* Main query detecting insecure SSL/TLS version usage */
from
  DataFlow::Node vulnerableNode, string protocolVersion, 
  InsecureProtocolConfiguration configNode, boolean isSpecific
where
  /* Scenario 1: Context-based insecure connection */
  (
    unsafe_connection_creation_with_context(vulnerableNode, protocolVersion, configNode, isSpecific)
  )
  or
  /* Scenario 2: Context-free insecure connection */
  (
    unsafe_connection_creation_without_context(vulnerableNode, protocolVersion) and
    configNode = vulnerableNode and
    isSpecific = true
  )
  or
  /* Scenario 3: Insecure context initialization */
  (
    unsafe_context_creation(configNode, protocolVersion) and
    vulnerableNode = configNode and
    isSpecific = true
  )
select vulnerableNode,
  "Insecure SSL/TLS protocol version " + protocolVersion + " " + getSpecificityVerb(isSpecific) + " by $@.",
  configNode, getConfigurationDescription(configNode)