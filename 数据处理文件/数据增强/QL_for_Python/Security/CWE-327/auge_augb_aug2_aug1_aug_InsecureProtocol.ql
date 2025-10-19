/**
 * @name Use of insecure SSL/TLS version
 * @description Detects usage of deprecated SSL/TLS protocol versions that expose connections to security vulnerabilities.
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

/* Represents nodes that configure deprecated SSL/TLS protocol versions */
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    /* Case 1: Creating vulnerable connection with security context */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* Case 2: Creating vulnerable connection without security context */
    unsafe_connection_creation_without_context(this, _)
    or
    /* Case 3: Creating insecure security context */
    unsafe_context_creation(this, _)
  }

  /* Retrieves the function node associated with this configuration */
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

/* Represents nodes that can be identified by name (function calls or attribute references) */
class IdentifiableNode extends DataFlow::Node {
  IdentifiableNode() {
    /* Case 1: Node is a function from protocol configuration */
    this = any(InsecureProtocolConfig insecureConfig).getAssociatedFunction()
    or
    /* Case 2: Node is an attribute reference of another identifiable node */
    this = any(IdentifiableNode attributeNode).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs the fully qualified name for an identifiable node */
string getFullyQualifiedName(IdentifiableNode identifiableNode) {
  /* Case 1: Direct function name */
  result = identifiableNode.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attributeRef | 
    attributeRef = identifiableNode and
    result = getFullyQualifiedName(attributeRef.getObject()) + "." + attributeRef.getAttributeName()
  )
}

/* Generates descriptive text for protocol configuration */
string getConfigDescription(InsecureProtocolConfig configurationNode) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode functionCall | 
    functionCall = configurationNode and
    result = "call to " + getFullyQualifiedName(functionCall.getFunction())
  )
  or
  /* Case 2: Context modification (non-call, non-context creation) */
  not configurationNode instanceof DataFlow::CallCfgNode and
  not configurationNode instanceof ContextCreation and
  result = "context modification"
}

/* Determines appropriate verb based on explicit configuration flag */
string getAppropriateVerb(boolean explicitFlag) {
  explicitFlag = true and result = "specified"
  or
  explicitFlag = false and result = "allowed"
}

/* Query to identify usage of deprecated SSL/TLS protocol versions */
from
  DataFlow::Node vulnerableCodeNode, string protocolVersion, 
  InsecureProtocolConfig configurationNode, boolean explicitFlag
where
  /* Case 1: Insecure connection with security context */
  (
    unsafe_connection_creation_with_context(vulnerableCodeNode, protocolVersion, configurationNode, explicitFlag)
  )
  or
  /* Case 2: Insecure connection without security context */
  (
    unsafe_connection_creation_without_context(vulnerableCodeNode, protocolVersion) and
    configurationNode = vulnerableCodeNode and
    explicitFlag = true
  )
  or
  /* Case 3: Insecure security context creation */
  (
    unsafe_context_creation(configurationNode, protocolVersion) and
    vulnerableCodeNode = configurationNode and
    explicitFlag = true
  )
select vulnerableCodeNode,
  "Insecure SSL/TLS protocol version " + protocolVersion + " " + getAppropriateVerb(explicitFlag) + " by $@.",
  configurationNode, getConfigDescription(configurationNode)