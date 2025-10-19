/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies code that uses deprecated SSL/TLS protocol versions, which can expose connections to known security vulnerabilities.
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
class InsecureSSLConfig extends DataFlow::Node {
  InsecureSSLConfig() {
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
class NamedNode extends DataFlow::Node {
  NamedNode() {
    /* Case 1: Node is a function from protocol configuration */
    this = any(InsecureSSLConfig insecureConfig).getAssociatedFunction()
    or
    /* Case 2: Node is an attribute reference of another identifiable node */
    this = any(NamedNode attributeNode).(DataFlow::AttrRef).getObject()
  }
}

/* Constructs the fully qualified name for a named node */
string getQualifiedName(NamedNode namedNode) {
  /* Case 1: Direct function name */
  result = namedNode.asExpr().(Name).getId()
  or
  /* Case 2: Attribute access chain */
  exists(DataFlow::AttrRef attributeRef | 
    attributeRef = namedNode and
    result = getQualifiedName(attributeRef.getObject()) + "." + attributeRef.getAttributeName()
  )
}

/* Helper functions for generating descriptive text */

/* Generates descriptive text for SSL configuration */
string getConfigurationDescription(InsecureSSLConfig configNode) {
  /* Case 1: Function call configuration */
  exists(DataFlow::CallCfgNode functionCall | 
    functionCall = configNode and
    result = "call to " + getQualifiedName(functionCall.getFunction())
  )
  or
  /* Case 2: Context modification (non-call, non-context creation) */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* Determines appropriate verb based on explicit configuration flag */
string getVerbForConfiguration(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

/* Query to identify usage of deprecated SSL/TLS protocol versions */
from
  DataFlow::Node vulnerableNode, string insecureProtocol, 
  InsecureSSLConfig configNode, boolean isExplicit
where
  /* Case 1: Insecure connection with security context */
  (
    unsafe_connection_creation_with_context(vulnerableNode, insecureProtocol, configNode, isExplicit)
  )
  or
  /* Case 2: Insecure connection without security context */
  (
    unsafe_connection_creation_without_context(vulnerableNode, insecureProtocol) and
    configNode = vulnerableNode and
    isExplicit = true
  )
  or
  /* Case 3: Insecure security context creation */
  (
    unsafe_context_creation(configNode, insecureProtocol) and
    vulnerableNode = configNode and
    isExplicit = true
  )
select vulnerableNode,
  "Insecure SSL/TLS protocol version " + insecureProtocol + " " + getVerbForConfiguration(isExplicit) + " by $@.",
  configNode, getConfigurationDescription(configNode)