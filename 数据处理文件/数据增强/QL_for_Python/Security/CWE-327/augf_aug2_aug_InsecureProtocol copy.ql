/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies the use of deprecated SSL/TLS protocol versions which can lead to security vulnerabilities in network connections.
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

// Represents nodes in the data flow that configure protocol settings
class ProtocolSettingNode extends DataFlow::Node {
  ProtocolSettingNode() {
    // Cases of insecure connection creation with context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Cases of insecure connection creation without context
    unsafe_connection_creation_without_context(this, _)
    or
    // Cases of insecure context initialization
    unsafe_context_creation(this, _)
  }

  // Retrieves the function node associated with this configuration
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

// Represents nodes that can be identified by qualified names
class QualifiedNameNode extends DataFlow::Node {
  QualifiedNameNode() {
    // Function nodes derived from protocol configurations
    this = any(ProtocolSettingNode config).getAssociatedFunction()
    or
    // Source nodes of attribute references
    this = any(QualifiedNameNode source).(DataFlow::AttrRef).getObject()
  }
}

// Generates qualified names for nodes that support naming
string generateQualifiedName(QualifiedNameNode node) {
  // Direct name resolution for identifier nodes
  result = node.asExpr().(Name).getId()
  or
  // Composite name resolution for attribute references
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = generateQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Creates descriptive labels for protocol configuration nodes
string generateConfigDescription(ProtocolSettingNode configNode) {
  // Description for function call configurations
  result = "call to " + generateQualifiedName(configNode.(DataFlow::CallCfgNode).getFunction())
  or
  // Description for non-call configurations
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

// Converts boolean flags to descriptive action verbs
string generateActionVerb(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

// Primary query for detecting insecure protocol version usage
from
  DataFlow::Node connectionNode, string vulnerableProtocol, 
  ProtocolSettingNode protocolSetting, boolean explicitFlag
where
  // Scenarios with context-based insecure connections
  unsafe_connection_creation_with_context(connectionNode, vulnerableProtocol, protocolSetting, explicitFlag)
  or
  // Scenarios with direct insecure connections
  unsafe_connection_creation_without_context(connectionNode, vulnerableProtocol) and
  protocolSetting = connectionNode and
  explicitFlag = true
  or
  // Scenarios with insecure context initialization
  unsafe_context_creation(protocolSetting, vulnerableProtocol) and
  connectionNode = protocolSetting and
  explicitFlag = true
select connectionNode,
  "Insecure SSL/TLS protocol version " + vulnerableProtocol + " " + generateActionVerb(explicitFlag) + 
  " by $@.", protocolSetting, generateConfigDescription(protocolSetting)