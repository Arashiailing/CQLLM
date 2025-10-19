/**
 * @name Unsafe usage of v1 version of Azure Storage client-side encryption.
 * @description Detects insecure use of version v1 Azure Storage client-side encryption, which could allow attackers to decrypt encrypted data
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

// Represents Azure Storage service client types and their initialization methods
API::Node blobServiceClient(boolean isDirectInstantiation) {
  // Direct BlobServiceClient instantiation
  isDirectInstantiation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // BlobServiceClient from connection string
  isDirectInstantiation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

API::CallNode containerClientCreation() {
  // Transition from BlobServiceClient to ContainerClient
  result = blobServiceClient(_).getMember("get_container_client").getACall()
  or
  // Transition from BlobClient to ContainerClient
  result = blobClient(_).getMember("_get_container_client").getACall()
}

API::Node containerClient(boolean isDirectInstantiation) {
  // ContainerClient obtained through transition
  isDirectInstantiation = false and
  result = containerClientCreation().getReturn()
  or
  // Direct ContainerClient instantiation
  isDirectInstantiation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // ContainerClient from connection string or URL
  isDirectInstantiation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

API::CallNode blobClientCreation() {
  // Transition from BlobServiceClient or ContainerClient to BlobClient
  result = [blobServiceClient(_), containerClient(_)]
        .getMember("get_blob_client")
        .getACall()
}

API::Node blobClient(boolean isDirectInstantiation) {
  // BlobClient obtained through transition
  isDirectInstantiation = false and
  result = blobClientCreation().getReturn()
  or
  // Direct BlobClient instantiation
  isDirectInstantiation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // BlobClient from connection string or URL
  isDirectInstantiation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

// Unified representation of all Azure Storage client types
API::Node azureStorageClient(boolean isDirectInstantiation) {
  result in [blobServiceClient(isDirectInstantiation), containerClient(isDirectInstantiation), blobClient(isDirectInstantiation)]
}

// Encryption state tracking for data flow analysis
newtype TEncryptionState =
  MkV1EncryptionState() or
  MkNoEncryptionState()

// Configuration for data flow analysis with encryption state tracking
private module EncryptionFlowConfig implements DataFlow::StateConfigSig {
  class FlowState = TEncryptionState;

  // Source nodes: uninitialized clients (no encryption configured)
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = MkNoEncryptionState() and
    node = azureStorageClient(true).asSource()
  }

  // Barrier nodes: clients explicitly configured with v2 encryption
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(state) and
    exists(DataFlow::AttrWrite encryptionAttr |
      node = azureStorageClient(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(node, "encryption_version") and
      encryptionAttr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // Barrier for state transition when encryption is configured
    isAdditionalFlowStep(_, MkNoEncryptionState(), node, MkV1EncryptionState()) and
    state = MkNoEncryptionState()
  }

  // Flow transitions between client objects
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [containerClientCreation(), blobClientCreation()] and
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
    exists(DataFlow::AttrWrite encryptionAttr |
      node1 = azureStorageClient(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // Sink nodes: v1 encrypted blob upload operations
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = MkV1EncryptionState() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = blobClient(_).getMember("upload_blob").getACall() and
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