/**
 * @name Use of insecure SSL/TLS version
 * @description Detects applications using deprecated SSL/TLS protocol versions that may expose connections to security vulnerabilities.
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

/**
 * Represents nodes that configure SSL/TLS protocols with potentially insecure versions.
 * This class captures three main scenarios:
 * 1. Creating insecure connections with context
 * 2. Creating insecure connections without context
 * 3. Creating insecure context objects
 */
class InsecureProtocolConfig extends DataFlow::Node {
  InsecureProtocolConfig() {
    // Case 1: Creating an insecure connection with context
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // Case 2: Creating an insecure connection without context
    unsafe_connection_creation_without_context(this, _)
    or
    // Case 3: Creating an insecure context
    unsafe_context_creation(this, _)
  }

  /**
   * Retrieves the function node associated with this configuration.
   * @return The function node associated with this configuration.
   */
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/**
 * Represents nodes that can be identified by name, such as function calls or attribute references.
 * This includes:
 * 1. Functions within protocol configurations
 * 2. Attribute references on other identifiable nodes
 */
class IdentifiableNode extends DataFlow::Node {
  IdentifiableNode() {
    // Case 1: Node is a function in a protocol configuration
    this = any(InsecureProtocolConfig ipc).getAssociatedFunction()
    or
    // Case 2: Node is an attribute reference on another identifiable node
    this = any(IdentifiableNode attr).(DataFlow::AttrRef).getObject()
  }
}

/**
 * Computes the fully qualified name of an identifiable node.
 * @param node The node for which to compute the qualified name.
 * @return The fully qualified name of the node.
 */
string getFullQualifiedName(IdentifiableNode node) {
  // Case 1: Direct function name
  result = node.asExpr().(Name).getId()
  or
  // Case 2: Attribute access chain
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getFullQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/**
 * Generates a descriptive name for a protocol configuration.
 * @param configNode The configuration node to describe.
 * @return A descriptive string for the configuration.
 */
string getConfigDescription(InsecureProtocolConfig configNode) {
  // Case 1: Function call configuration
  result = "call to " + getFullQualifiedName(configNode.(DataFlow::CallCfgNode).getFunction())
  or
  // Case 2: Context modification (non-call, non-context creation)
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/**
 * Determines the appropriate verb based on version specificity.
 * @param isSpecific Flag indicating if the version is specifically set.
 * @return "specified" if version is specific, "allowed" otherwise.
 */
string getAppropriateVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

/**
 * Main query to detect the use of insecure SSL/TLS protocol versions.
 * Identifies three main patterns of insecure protocol usage and reports them.
 */
from
  DataFlow::Node vulnerableConnectionNode, string insecureVersion, 
  InsecureProtocolConfig configNode, boolean isVersionSpecific
where
  // Case 1: Creating an insecure connection with context
  (
    unsafe_connection_creation_with_context(vulnerableConnectionNode, insecureVersion, configNode, isVersionSpecific)
  )
  or
  // Case 2: Creating an insecure connection without context
  (
    unsafe_connection_creation_without_context(vulnerableConnectionNode, insecureVersion) and
    configNode = vulnerableConnectionNode and
    isVersionSpecific = true
  )
  or
  // Case 3: Creating an insecure context
  (
    unsafe_context_creation(configNode, insecureVersion) and
    vulnerableConnectionNode = configNode and
    isVersionSpecific = true
  )
select vulnerableConnectionNode,
  "Insecure SSL/TLS protocol version " + insecureVersion + " " + getAppropriateVerb(isVersionSpecific) + " by $@.",
  configNode, getConfigDescription(configNode)