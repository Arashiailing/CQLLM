/**
 * @name Use of insecure SSL/TLS version
 * @description Detects usage of deprecated SSL/TLS protocol versions vulnerable to attacks.
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

// Represents nodes configuring insecure protocol settings
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    // Handles connections created with security context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Handles connections created without security context
    unsafe_connection_creation_without_context(this, _)
    or
    // Handles direct insecure context creation
    unsafe_context_creation(this, _)
  }

  // Retrieves the associated function node
  DataFlow::Node getFunctionNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

// Represents nodes that can be named (functions or attribute accesses)
class NamedNode extends DataFlow::Node {
  NamedNode() {
    // Matches function nodes from protocol configurations
    this = any(InsecureProtocolConfig cfg).getFunctionNode()
    or
    // Matches attribute access objects
    this = any(NamedNode attr).(DataFlow::AttrRef).getObject()
  }
}

// Constructs qualified names for callable nodes
string getQualifiedName(NamedNode node) {
  // Base case: direct function name
  result = node.asExpr().(Name).getId()
  or
  // Recursive case: attribute access chains
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

// Generates human-readable configuration descriptions
string getConfigDescription(InsecureProtocolConfig config) {
  // Case 1: Function call configuration
  result = "call to " + getQualifiedName(config.(DataFlow::CallCfgNode).getFunction())
  or
  // Case 2: Non-callable configuration (context modification)
  not config instanceof DataFlow::CallCfgNode and
  not config instanceof ContextCreation and
  result = "context modification"
}

// Selects appropriate verb based on configuration specificity
string getVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

// Main query detecting insecure protocol usage
from
  DataFlow::Node insecureConnCreation, string insecureVersion, 
  InsecureProtocolConfig protocolConfig, boolean isSpecific
where
  // Scenario 1: Context-based insecure connection
  unsafe_connection_creation_with_context(insecureConnCreation, insecureVersion, protocolConfig, isSpecific)
  or
  // Scenario 2: Direct insecure connection (no context)
  unsafe_connection_creation_without_context(insecureConnCreation, insecureVersion) and
  protocolConfig = insecureConnCreation and
  isSpecific = true
  or
  // Scenario 3: Insecure context creation
  unsafe_context_creation(protocolConfig, insecureVersion) and
  insecureConnCreation = protocolConfig and
  isSpecific = true
select insecureConnCreation,
  "Insecure SSL/TLS protocol version " + insecureVersion + " " + getVerb(isSpecific) + " by $@.",
  protocolConfig, getConfigDescription(protocolConfig)