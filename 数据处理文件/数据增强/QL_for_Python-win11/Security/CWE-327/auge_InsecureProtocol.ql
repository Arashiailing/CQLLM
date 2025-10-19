/**
 * @name Use of insecure SSL/TLS version
 * @description Detects usage of deprecated SSL/TLS protocol versions that may expose connections to security vulnerabilities.
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

// Represents protocol configuration nodes in data flow analysis
class ProtocolConfiguration extends DataFlow::Node {
  ProtocolConfiguration() {
    // Handles connections created with security context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Handles connections created without security context
    unsafe_connection_creation_without_context(this, _)
    or
    // Handles security context configurations
    unsafe_context_creation(this, _)
  }

  // Retrieves the function node associated with this configuration
  DataFlow::Node getNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

// Represents nodes that can be named in code analysis
class Nameable extends DataFlow::Node {
  Nameable() {
    // Nodes that are functions from protocol configurations
    this = any(ProtocolConfiguration pc).getNode()
    or
    // Nodes that are attribute references on nameable objects
    this = any(Nameable attr).(DataFlow::AttrRef).getObject()
  }
}

// Generates the call name for a nameable node
string callName(Nameable node) {
  // Direct name expressions
  result = node.asExpr().(Name).getId()
  or
  // Attribute references (object.attribute format)
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = callName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates descriptive name for protocol configurations
string configName(ProtocolConfiguration configNode) {
  // Named function calls
  result = "call to " + callName(configNode.(DataFlow::CallCfgNode).getFunction())
  or
  // Non-call context modifications
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

// Provides verb based on specificity flag
string verb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

// Main query detecting insecure protocol usage
from
  DataFlow::Node connectionCreation, string insecure_version, 
  DataFlow::Node protocolConfig, boolean isSpecific
where
  // Case 1: Context-based insecure connections
  unsafe_connection_creation_with_context(connectionCreation, insecure_version,
    protocolConfig, isSpecific)
  or
  // Case 2: Direct insecure connections
  unsafe_connection_creation_without_context(connectionCreation, insecure_version) and
  protocolConfig = connectionCreation and
  isSpecific = true
  or
  // Case 3: Insecure context configurations
  unsafe_context_creation(protocolConfig, insecure_version) and
  connectionCreation = protocolConfig and
  isSpecific = true
select connectionCreation,
  "Insecure SSL/TLS protocol version " + insecure_version + " " + verb(isSpecific) + " by $@.",
  protocolConfig, configName(protocolConfig)