/**
 * @name Use of insecure SSL/TLS version
 * @description Identifies applications using deprecated SSL/TLS protocol versions that could expose connections to security vulnerabilities.
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

// Represents nodes involved in protocol configuration during data flow analysis
class ProtocolConfigNode extends DataFlow::Node {
  ProtocolConfigNode() {
    // Handles context-based insecure connection establishment
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Handles direct insecure connection establishment
    unsafe_connection_creation_without_context(this, _)
    or
    // Handles insecure context initialization
    unsafe_context_creation(this, _)
  }

  // Obtains the function node associated with this configuration
  DataFlow::Node getAssociatedFunction() { 
    result = this.(DataFlow::CallCfgNode).getFunction() 
  }
}

// Represents nodes that can be resolved to qualified names
class QualifiedNameNode extends DataFlow::Node {
  QualifiedNameNode() {
    // Nodes corresponding to functions in protocol configurations
    this = any(ProtocolConfigNode config).getAssociatedFunction()
    or
    // Nodes accessed through attribute references
    this = any(QualifiedNameNode source).(DataFlow::AttrRef).getObject()
  }
}

// Generates fully qualified names for resolvable nodes
string getFullQualifiedName(QualifiedNameNode node) {
  // Handles direct name resolution for identifier nodes
  result = node.asExpr().(Name).getId()
  or
  // Handles composite name resolution for attribute references
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getFullQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates descriptive labels for protocol configurations
string getConfigDescriptor(ProtocolConfigNode config) {
  // Describes function call configurations
  result = "call to " + getFullQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Describes non-call, non-context configurations
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Maps boolean flags to action verbs
string getActionVerb(boolean isExplicit) {
  isExplicit = true and result = "specified"
  or
  isExplicit = false and result = "allowed"
}

// Main query identifying insecure protocol usage
from
  DataFlow::Node connectionPoint, string protocolVersion, 
  ProtocolConfigNode configSource, boolean explicitFlag
where
  // Context-based insecure connection scenarios
  unsafe_connection_creation_with_context(connectionPoint, protocolVersion, configSource, explicitFlag)
  or
  // Direct insecure connection scenarios
  unsafe_connection_creation_without_context(connectionPoint, protocolVersion) and
  configSource = connectionPoint and
  explicitFlag = true
  or
  // Insecure context initialization scenarios
  unsafe_context_creation(configSource, protocolVersion) and
  connectionPoint = configSource and
  explicitFlag = true
select connectionPoint,
  "Insecure SSL/TLS protocol version " + protocolVersion + " " + getActionVerb(explicitFlag) + 
  " by $@.", configSource, getConfigDescriptor(configSource)