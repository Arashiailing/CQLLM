/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies deprecated SSL/TLS protocol implementations that may introduce security vulnerabilities.
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

// Represents protocol configuration points in data flow analysis
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    // Handles context-based insecure connection establishment
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Handles direct insecure connection establishment
    unsafe_connection_creation_without_context(this, _)
    or
    // Handles insecure context initialization
    unsafe_context_creation(this, _)
  }

  // Retrieves the associated function node for this configuration
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

// Represents nodes that can be identified with a qualified name
class QualifiedNode extends DataFlow::Node {
  QualifiedNode() {
    // Nodes that are functions of protocol configurations
    this = any(InsecureProtocolConfig config).getAssociatedFunction()
    or
    // Nodes accessed through attribute references
    this = any(QualifiedNode source).(DataFlow::AttrRef).getObject()
  }
}

// Generates qualified names for identifiable nodes
string getQualName(QualifiedNode node) {
  // Direct name resolution for identifier nodes
  result = node.asExpr().(Name).getId()
  or
  // Composite name resolution for attribute references
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates descriptive labels for protocol configurations
string getConfigDesc(InsecureProtocolConfig config) {
  // Label for function call configurations
  result = "call to " + getQualName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Label for non-call, non-context configurations
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Maps boolean flags to descriptive action verbs
string getVerb(boolean explicitFlag) {
  explicitFlag = true and result = "specified"
  or
  explicitFlag = false and result = "allowed"
}

// Primary query detecting insecure protocol usage
from
  DataFlow::Node insecureConn, string protocolVersion, 
  InsecureProtocolConfig protocolConfig, boolean explicitFlag
where
  // Context-based insecure connection scenarios
  (unsafe_connection_creation_with_context(insecureConn, protocolVersion, protocolConfig, explicitFlag))
  or
  // Direct insecure connection scenarios
  (unsafe_connection_creation_without_context(insecureConn, protocolVersion) and
   protocolConfig = insecureConn and
   explicitFlag = true)
  or
  // Insecure context initialization scenarios
  (unsafe_context_creation(protocolConfig, protocolVersion) and
   insecureConn = protocolConfig and
   explicitFlag = true)
select insecureConn,
  "Insecure SSL/TLS protocol version " + protocolVersion + " " + getVerb(explicitFlag) + 
  " by $@.", protocolConfig, getConfigDesc(protocolConfig)