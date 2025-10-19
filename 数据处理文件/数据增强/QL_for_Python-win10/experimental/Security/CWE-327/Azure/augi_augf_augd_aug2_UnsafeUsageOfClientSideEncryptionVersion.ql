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

// Azure Storage BlobServiceClient initialization patterns
API::Node getBlobServiceClientNode(boolean isSource) {
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

// Client transitions to ContainerClient
API::CallNode getContainerClientTransitionCall() {
  // Transition from BlobServiceClient to ContainerClient
  result = getBlobServiceClientNode(_).getMember("get_container_client").getACall()
  or
  // Transition from BlobClient to ContainerClient
  result = getBlobClientNode(_).getMember("_get_container_client").getACall()
}

// Azure Storage ContainerClient initialization patterns
API::Node getContainerClientNode(boolean isSource) {
  // ContainerClient obtained through transition
  isSource = false and
  result = getContainerClientTransitionCall().getReturn()
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

// Client transitions to BlobClient
API::CallNode getBlobClientTransitionCall() {
  // Transition from BlobServiceClient or ContainerClient to BlobClient
  result = [getBlobServiceClientNode(_), getContainerClientNode(_)]
        .getMember("get_blob_client")
        .getACall()
}

// Azure Storage BlobClient initialization patterns
API::Node getBlobClientNode(boolean isSource) {
  // BlobClient obtained through transition
  isSource = false and
  result = getBlobClientTransitionCall().getReturn()
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

// Unified representation of all Azure Storage client types
API::Node getAzureStorageClientNode(boolean isSource) {
  result in [getBlobServiceClientNode(isSource), getContainerClientNode(isSource), getBlobClientNode(isSource)]
}

// Encryption state definitions for data flow tracking
newtype EncryptionState =
  V1EncryptionState() or
  NoEncryptionState()

// Data flow configuration with encryption state tracking
private module EncryptionConfig implements DataFlow::StateConfigSig {
  class FlowState = EncryptionState;

  // Source nodes: uninitialized clients (no encryption configured)
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = NoEncryptionState() and
    node = getAzureStorageClientNode(true).asSource()
  }

  // Barrier nodes: clients explicitly configured with v2 encryption
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(DataFlow::AttrWrite encryptionAttrWrite |
      node = getAzureStorageClientNode(_).getAValueReachableFromSource() and
      encryptionAttrWrite.accesses(node, "encryption_version") and
      encryptionAttrWrite.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // Barrier for state transition when encryption is configured
    isAdditionalFlowStep(_, NoEncryptionState(), node, V1EncryptionState()) and
    state = NoEncryptionState()
  }

  // Flow transitions between client objects
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [getContainerClientTransitionCall(), getBlobClientTransitionCall()] and
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
    exists(DataFlow::AttrWrite encryptionAttrWrite |
      node1 = getAzureStorageClientNode(_).getAValueReachableFromSource() and
      encryptionAttrWrite.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // Sink nodes: v1 encrypted blob upload operations
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = V1EncryptionState() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = getBlobClientNode(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // No restrictions on incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis with encryption state tracking
module EncryptionDataFlow = DataFlow::GlobalWithState<EncryptionConfig>;

import EncryptionDataFlow::PathGraph

// Query: Identify unsafe v1 encryption usage paths
from EncryptionDataFlow::PathNode sourceNode, EncryptionDataFlow::PathNode sinkNode
where EncryptionDataFlow::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "Unsafe usage of v1 version of Azure Storage client-side encryption"