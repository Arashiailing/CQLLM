/**
 * @name Insecure Azure Storage v1 client-side encryption usage
 * @description Detects unsafe v1 encryption implementation in Azure Storage clients that may expose encrypted data
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

// Azure Storage client initialization methods
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

API::CallNode containerClientCreationCall() {
  // Transition from BlobServiceClient to ContainerClient
  result = azureBlobServiceClientNode(_).getMember("get_container_client").getACall()
  or
  // Transition from BlobClient to ContainerClient
  result = azureBlobClientNode(_).getMember("_get_container_client").getACall()
}

API::Node azureContainerClientNode(boolean isDirectlyCreated) {
  // ContainerClient obtained through transition
  isDirectlyCreated = false and
  result = containerClientCreationCall().getReturn()
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

API::CallNode blobClientCreationCall() {
  // Transition from BlobServiceClient or ContainerClient to BlobClient
  result = [azureBlobServiceClientNode(_), azureContainerClientNode(_)]
        .getMember("get_blob_client")
        .getACall()
}

API::Node azureBlobClientNode(boolean isDirectlyCreated) {
  // BlobClient obtained through transition
  isDirectlyCreated = false and
  result = blobClientCreationCall().getReturn()
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

// Unified representation of Azure Storage client types
API::Node anyAzureStorageClientNode(boolean isDirectlyCreated) {
  result in [azureBlobServiceClientNode(isDirectlyCreated), 
             azureContainerClientNode(isDirectlyCreated), 
             azureBlobClientNode(isDirectlyCreated)]
}

// Encryption state tracking definitions
newtype EncryptionFlowState =
  V1EncryptionState() or
  NoEncryptionState()

// Data flow configuration with encryption state tracking
private module EncryptionFlowConfiguration implements DataFlow::StateConfigSig {
  class FlowState = EncryptionFlowState;

  // Source nodes: uninitialized clients (no encryption configured)
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = NoEncryptionState() and
    node = anyAzureStorageClientNode(true).asSource()
  }

  // Barrier nodes: clients explicitly configured with v2 encryption
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(state) and
    exists(DataFlow::AttrWrite encryptionAttr |
      node = anyAzureStorageClientNode(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(node, "encryption_version") and
      encryptionAttr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // Barrier for state transition when encryption is configured
    isAdditionalFlowStep(_, NoEncryptionState(), node, V1EncryptionState()) and
    state = NoEncryptionState()
  }

  // Flow transitions between client objects
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [containerClientCreationCall(), blobClientCreationCall()] and
      node1 = transitionCall.getObject() and
      node2 = transitionCall
    )
  }

  // State transition when encryption configuration is applied
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = NoEncryptionState() and
    state2 = V1EncryptionState() and
    exists(DataFlow::AttrWrite encryptionAttr |
      node1 = anyAzureStorageClientNode(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // Sink nodes: v1 encrypted blob upload operations
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = V1EncryptionState() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = azureBlobClientNode(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // No restrictions on incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis with encryption state tracking
module EncryptionDataFlowAnalysis = DataFlow::GlobalWithState<EncryptionFlowConfiguration>;

import EncryptionDataFlowAnalysis::PathGraph

// Query: Identify unsafe v1 encryption usage paths
from EncryptionDataFlowAnalysis::PathNode sourceNode, EncryptionDataFlowAnalysis::PathNode sinkNode
where EncryptionDataFlowAnalysis::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "Unsafe usage of v1 version of Azure Storage client-side encryption"