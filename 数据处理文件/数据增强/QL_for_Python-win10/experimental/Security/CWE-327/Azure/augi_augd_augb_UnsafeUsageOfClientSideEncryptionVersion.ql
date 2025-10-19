/**
 * @name Unsafe usage of v1 version of Azure Storage client-side encryption
 * @description Detects insecure use of Azure Storage client-side encryption v1, which may allow attackers to decrypt encrypted data
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

// Represents Azure Storage service client initialization paths
API::Node azureBlobServiceClient(boolean isSource) {
  // Direct BlobServiceClient initialization
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

// Represents transitions to container client instances
API::CallNode containerClientTransition() {
  // Container client transition from blob service client
  result = azureBlobServiceClient(_).getMember("get_container_client").getACall()
  or
  // Container client transition from blob client
  result = azureBlobClient(_).getMember("_get_container_client").getACall()
}

// Represents Azure Storage container client initialization paths
API::Node azureContainerClient(boolean isSource) {
  // Container client from transition calls
  isSource = false and
  result = containerClientTransition().getReturn()
  or
  // Direct ContainerClient initialization
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

// Represents transitions to blob client instances
API::CallNode blobClientTransition() {
  // Blob client transition from service or container clients
  result = [azureBlobServiceClient(_), azureContainerClient(_)]
        .getMember("get_blob_client")
        .getACall()
}

// Represents Azure Storage blob client initialization paths
API::Node azureBlobClient(boolean isSource) {
  // Blob client from transition calls
  isSource = false and
  result = blobClientTransition().getReturn()
  or
  // Direct BlobClient initialization
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

// Unified representation of all Azure Storage client types
API::Node anyAzureStorageClient(boolean isSource) {
  result in [azureBlobServiceClient(isSource), azureContainerClient(isSource), azureBlobClient(isSource)]
}

// States representing encryption configuration
newtype AzureEncryptionState =
  V1Encryption() or
  NoEncryption()

// Data flow configuration for tracking encryption states
private module AzureEncryptionFlow implements DataFlow::StateConfigSig {
  class FlowState = AzureEncryptionState;

  // Source: Any client without explicit encryption configuration
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = NoEncryption() and
    node = anyAzureStorageClient(true).asSource()
  }

  // Client transition flow steps
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [containerClientTransition(), blobClientTransition()] and
      node1 = transitionCall.getObject() and
      node2 = transitionCall
    )
  }

  // State transition: No encryption -> v1 encryption
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = NoEncryption() and
    state2 = V1Encryption() and
    exists(DataFlow::AttrWrite encryptionAttr |
      node1 = anyAzureStorageClient(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
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
    isAdditionalFlowStep(_, NoEncryption(), node, V1Encryption()) and
    state = NoEncryption()
  }

  // Sink: Blob upload with v1 encryption
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = V1Encryption() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = azureBlobClient(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // Incremental mode configuration
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis module
module AzureEncryptionDataFlow = DataFlow::GlobalWithState<AzureEncryptionFlow>;
import AzureEncryptionDataFlow::PathGraph

// Query: Find paths from unconfigured clients to v1 encrypted blob uploads
from AzureEncryptionDataFlow::PathNode sourceNode, AzureEncryptionDataFlow::PathNode sinkNode
where AzureEncryptionDataFlow::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "Unsafe usage of v1 version of Azure Storage client-side encryption"