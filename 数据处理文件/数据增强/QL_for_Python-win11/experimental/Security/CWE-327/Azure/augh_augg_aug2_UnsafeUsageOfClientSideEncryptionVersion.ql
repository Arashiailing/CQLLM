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

// Represents Azure Storage BlobServiceClient initialization patterns
API::Node azureBlobServiceClientNode(boolean isDirectlyCreated) {
  // Direct BlobServiceClient instantiation
  isDirectlyCreated = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // BlobServiceClient from connection string
  isDirectlyCreated = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

// Represents transitions from BlobServiceClient to ContainerClient
API::CallNode containerClientCreationTransition() {
  // Transition from BlobServiceClient to ContainerClient
  result = azureBlobServiceClientNode(_).getMember("get_container_client").getACall()
  or
  // Transition from BlobClient to ContainerClient
  result = azureBlobClientNode(_).getMember("_get_container_client").getACall()
}

// Represents Azure Storage ContainerClient initialization patterns
API::Node azureContainerClientNode(boolean isDirectlyCreated) {
  // ContainerClient obtained through transition
  isDirectlyCreated = false and
  result = containerClientCreationTransition().getReturn()
  or
  // Direct ContainerClient instantiation
  isDirectlyCreated = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // ContainerClient from connection string or URL
  isDirectlyCreated = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

// Represents transitions from BlobServiceClient/ContainerClient to BlobClient
API::CallNode blobClientCreationTransition() {
  // Transition from BlobServiceClient or ContainerClient to BlobClient
  result = [azureBlobServiceClientNode(_), azureContainerClientNode(_)]
        .getMember("get_blob_client")
        .getACall()
}

// Represents Azure Storage BlobClient initialization patterns
API::Node azureBlobClientNode(boolean isDirectlyCreated) {
  // BlobClient obtained through transition
  isDirectlyCreated = false and
  result = blobClientCreationTransition().getReturn()
  or
  // Direct BlobClient instantiation
  isDirectlyCreated = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // BlobClient from connection string or URL
  isDirectlyCreated = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

// Unified representation of all Azure Storage client types
API::Node azureStorageClientNode(boolean isDirectlyCreated) {
  result in [
    azureBlobServiceClientNode(isDirectlyCreated),
    azureContainerClientNode(isDirectlyCreated),
    azureBlobClientNode(isDirectlyCreated)
  ]
}

// Encryption state tracking for data flow analysis
newtype TEncryptionFlowState =
  MkV1EncryptionState() or
  MkNoEncryptionState()

// Configuration for data flow analysis with encryption state tracking
private module EncryptionFlowConfig implements DataFlow::StateConfigSig {
  class FlowState = TEncryptionFlowState;

  // Source nodes: uninitialized clients (no encryption configured)
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = MkNoEncryptionState() and
    node = azureStorageClientNode(true).asSource()
  }

  // Barrier nodes: clients explicitly configured with v2 encryption
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(state) and
    exists(DataFlow::AttrWrite encryptionVersionAttr |
      node = azureStorageClientNode(_).getAValueReachableFromSource() and
      encryptionVersionAttr.accesses(node, "encryption_version") and
      encryptionVersionAttr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // Barrier for state transition when encryption is configured
    isAdditionalFlowStep(_, MkNoEncryptionState(), node, MkV1EncryptionState()) and
    state = MkNoEncryptionState()
  }

  // Flow transitions between client objects
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [containerClientCreationTransition(), blobClientCreationTransition()] and
      node1 = transitionCall.getObject() and
      node2 = transitionCall
    )
  }

  // State transition when encryption configuration is applied
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = MkNoEncryptionState() and
    state2 = MkV1EncryptionState() and
    exists(DataFlow::AttrWrite encryptionKeyAttr |
      node1 = azureStorageClientNode(_).getAValueReachableFromSource() and
      encryptionKeyAttr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // Sink nodes: v1 encrypted blob upload operations
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = MkV1EncryptionState() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = azureBlobClientNode(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // No restrictions on incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis with encryption state tracking
module EncryptionDataFlow = DataFlow::GlobalWithState<EncryptionFlowConfig>;

import EncryptionDataFlow::PathGraph

// Query: Identify unsafe v1 encryption usage paths
from EncryptionDataFlow::PathNode sourceNode, EncryptionDataFlow::PathNode sinkNode
where EncryptionDataFlow::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "Unsafe usage of v1 version of Azure Storage client-side encryption"