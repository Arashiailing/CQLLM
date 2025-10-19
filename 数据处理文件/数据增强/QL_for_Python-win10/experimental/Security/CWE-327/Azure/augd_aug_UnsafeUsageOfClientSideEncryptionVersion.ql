/**
 * Detects insecure usage of Azure Storage client-side encryption v1.
 * @description Using version v1 of Azure Storage client-side encryption is insecure, potentially allowing attackers to decrypt encrypted data
 * @kind path-problem
 * @tags security
 *       experimental
 *       cryptography
 *       external/cwe/cwe-327
 * @id py/azure-storage/unsafe-client-side-encryption-in-use
 * @problem.severity error
 * @precision medium
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

/**
 * Retrieves API nodes for Blob service client instances.
 * @param isSource - Flag indicating if node represents client creation source
 * @returns API node for Blob service client
 */
API::Node getBlobServiceClientNode(boolean isSource) {
  // Handle direct BlobServiceClient instantiation
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // Handle BlobServiceClient creation via connection string
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

/**
 * Retrieves call nodes that transition to container clients.
 * @returns API call node for container client transition
 */
API::CallNode getContainerClientTransitionCall() {
  // Handle container client retrieval from blob service client
  result = getBlobServiceClientNode(_).getMember("get_container_client").getACall()
  or
  // Handle container client retrieval from blob client
  result = getBlobClientNode(_).getMember("_get_container_client").getACall()
}

/**
 * Retrieves API nodes for container client instances.
 * @param isSource - Flag indicating if node represents client creation source
 * @returns API node for container client
 */
API::Node getContainerClientNode(boolean isSource) {
  // Handle container client from transition calls
  isSource = false and
  result = getContainerClientTransitionCall().getReturn()
  or
  // Handle direct ContainerClient instantiation
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // Handle ContainerClient creation via connection string or URL
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

/**
 * Retrieves call nodes that transition to blob clients.
 * @returns API call node for blob client transition
 */
API::CallNode getBlobClientTransitionCall() {
  // Handle blob client retrieval from blob service or container clients
  result = [getBlobServiceClientNode(_), getContainerClientNode(_)]
        .getMember("get_blob_client")
        .getACall()
}

/**
 * Retrieves API nodes for blob client instances.
 * @param isSource - Flag indicating if node represents client creation source
 * @returns API node for blob client
 */
API::Node getBlobClientNode(boolean isSource) {
  // Handle blob client from transition calls
  isSource = false and
  result = getBlobClientTransitionCall().getReturn()
  or
  // Handle direct BlobClient instantiation
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // Handle BlobClient creation via connection string or URL
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

/**
 * Retrieves any storage client API node (blob service, container, or blob).
 * @param isSource - Flag indicating if node represents client creation source
 * @returns API node for any storage client
 */
API::Node getAnyStorageClientNode(boolean isSource) {
  result in [
    getBlobServiceClientNode(isSource),
    getContainerClientNode(isSource),
    getBlobClientNode(isSource)
  ]
}

// Define encryption state types for Azure storage clients
newtype AzureEncryptionState =
  UsesV1Encryption()   // Indicates v1 encryption is in use
  or
  UsesNoEncryption()   // Indicates no encryption is configured

/**
 * Configuration module for tracking encryption states in Azure blob clients.
 * Implements DataFlow::StateConfigSig interface.
 */
private module AzureStorageClientConfig implements DataFlow::StateConfigSig {
  class FlowState = AzureEncryptionState;

  /**
   * Identifies source nodes where encryption might not be configured.
   * @param node - Data flow node to check
   * @param state - Flow state to set
   */
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = UsesNoEncryption() and
    node = getAnyStorageClientNode(true).asSource()
  }

  /**
   * Identifies barrier nodes where encryption is properly configured.
   * @param node - Data flow node to check
   * @param state - Flow state to check
   */
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(state) and
    // Detect explicit v2 encryption configuration
    exists(DataFlow::AttrWrite attrWrite |
      node = getAnyStorageClientNode(_).getAValueReachableFromSource() and
      attrWrite.accesses(node, "encryption_version") and
      attrWrite.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // Optimization: Prevent flow when encryption properties are set
    isAdditionalFlowStep(_, UsesNoEncryption(), node, UsesV1Encryption()) and
    state = UsesNoEncryption()
  }

  /**
   * Identifies additional flow steps between client objects.
   * @param node1 - Source node
   * @param node2 - Destination node
   */
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transCall |
      transCall in [getContainerClientTransitionCall(), getBlobClientTransitionCall()] and
      node1 = transCall.getObject() and
      node2 = transCall
    )
  }

  /**
   * Identifies state transitions during flow.
   * @param node1 - Source node
   * @param state1 - Source state
   * @param node2 - Destination node
   * @param state2 - Destination state
   */
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = UsesNoEncryption() and
    state2 = UsesV1Encryption() and
    // Detect encryption configuration that triggers v1 usage
    exists(DataFlow::AttrWrite attrWrite |
      node1 = getAnyStorageClientNode(_).getAValueReachableFromSource() and
      attrWrite.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  /**
   * Identifies sink nodes where v1 encryption is used for blob uploads.
   * @param node - Data flow node to check
   * @param state - Flow state to check
   */
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = UsesV1Encryption() and
    // Detect blob upload operations
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = getBlobClientNode(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // Enable differential analysis for incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis module with state tracking
module AzureStorageClientFlow = DataFlow::GlobalWithState<AzureStorageClientConfig>;

import AzureStorageClientFlow::PathGraph

/**
 * Main query to detect unsafe v1 encryption usage.
 * Finds paths from unencrypted sources to v1-encrypted blob uploads.
 */
from AzureStorageClientFlow::PathNode source, AzureStorageClientFlow::PathNode sink
where AzureStorageClientFlow::flowPath(source, sink)
select sink, source, sink, "Unsafe usage of v1 version of Azure Storage client-side encryption"