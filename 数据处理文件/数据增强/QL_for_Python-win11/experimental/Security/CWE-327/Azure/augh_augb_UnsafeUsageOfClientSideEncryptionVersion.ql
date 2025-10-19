/**
 * @name Unsafe usage of v1 version of Azure Storage client-side encryption.
 * @description Using version v1 of Azure Storage client-side encryption is insecure, and may enable an attacker to decrypt encrypted data
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

// Azure Storage client initialization paths
API::Node azureBlobServiceClientNode(boolean isSource) {
  // Direct BlobServiceClient instantiation
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // BlobServiceClient from connection string
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

API::CallNode containerClientTransitionCall() {
  // Container client transition from blob service client
  result = azureBlobServiceClientNode(_).getMember("get_container_client").getACall()
  or
  // Container client transition from blob client
  result = azureBlobClientNode(_).getMember("_get_container_client").getACall()
}

API::Node azureContainerClientNode(boolean isSource) {
  // Container client from transition calls
  isSource = false and
  result = containerClientTransitionCall().getReturn()
  or
  // Direct ContainerClient instantiation
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // ContainerClient from connection string or URL
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

API::CallNode blobClientTransitionCall() {
  // Blob client transition from service or container clients
  result = [azureBlobServiceClientNode(_), azureContainerClientNode(_)]
        .getMember("get_blob_client")
        .getACall()
}

API::Node azureBlobClientNode(boolean isSource) {
  // Blob client from transition calls
  isSource = false and
  result = blobClientTransitionCall().getReturn()
  or
  // Direct BlobClient instantiation
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // BlobClient from connection string or URL
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

// Unified representation of Azure Storage client types
API::Node anyAzureStorageClient(boolean isSource) {
  result in [azureBlobServiceClientNode(isSource), azureContainerClientNode(isSource), azureBlobClientNode(isSource)]
}

// Encryption configuration states
newtype AzureEncryptionState =
  V1EncryptionState() or
  NoEncryptionState()

// Data flow configuration for tracking encryption states
private module AzureEncryptionFlowConfig implements DataFlow::StateConfigSig {
  class FlowState = AzureEncryptionState;

  // Source: Any client without explicit encryption configuration
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = NoEncryptionState() and
    node = anyAzureStorageClient(true).asSource()
  }

  // Barrier: Explicit v2 encryption configuration or state transition
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    // v2 encryption version barrier
    exists(DataFlow::AttrWrite versionAttr |
      node = anyAzureStorageClient(_).getAValueReachableFromSource() and
      versionAttr.accesses(node, "encryption_version") and
      versionAttr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    ) and
    exists(state)
    or
    // State transition barrier
    isAdditionalFlowStep(_, NoEncryptionState(), node, V1EncryptionState()) and
    state = NoEncryptionState()
  }

  // Client transition flow steps
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [containerClientTransitionCall(), blobClientTransitionCall()] and
      node1 = transitionCall.getObject() and
      node2 = transitionCall
    )
  }

  // State transition: No encryption -> v1 encryption
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = NoEncryptionState() and
    state2 = V1EncryptionState() and
    exists(DataFlow::AttrWrite encryptionAttr |
      node1 = anyAzureStorageClient(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // Sink: Blob upload with v1 encryption
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = V1EncryptionState() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = azureBlobClientNode(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // Incremental mode configuration
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis module
module AzureEncryptionFlow = DataFlow::GlobalWithState<AzureEncryptionFlowConfig>;
import AzureEncryptionFlow::PathGraph

// Query: Find paths from unconfigured clients to v1 encrypted blob uploads
from AzureEncryptionFlow::PathNode sourceNode, AzureEncryptionFlow::PathNode sinkNode
where AzureEncryptionFlow::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "Unsafe usage of v1 version of Azure Storage client-side encryption"