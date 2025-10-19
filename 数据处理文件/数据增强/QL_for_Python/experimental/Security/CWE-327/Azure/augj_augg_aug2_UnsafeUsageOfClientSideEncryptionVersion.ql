/**
 * @name Detection of insecure Azure Storage client-side encryption v1 usage
 * @description Identifies paths where Azure Storage client-side encryption v1 is used,
 *              which could allow attackers to decrypt sensitive data
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

// Represents Azure Storage service clients and their initialization patterns
API::Node getBlobServiceClient(boolean directCreation) {
  // Handles direct BlobServiceClient instantiation
  directCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // Handles BlobServiceClient creation from connection strings
  directCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

API::CallNode getContainerClientTransition() {
  // Transition from BlobServiceClient to ContainerClient
  result = getBlobServiceClient(_).getMember("get_container_client").getACall()
  or
  // Transition from BlobClient to ContainerClient
  result = getBlobClient(_).getMember("_get_container_client").getACall()
}

API::Node getContainerClient(boolean directCreation) {
  // ContainerClient obtained through client transitions
  directCreation = false and
  result = getContainerClientTransition().getReturn()
  or
  // Direct ContainerClient instantiation
  directCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // ContainerClient from connection string or URL
  directCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

API::CallNode getBlobClientTransition() {
  // Transition from BlobServiceClient or ContainerClient to BlobClient
  result = [getBlobServiceClient(_), getContainerClient(_)]
        .getMember("get_blob_client")
        .getACall()
}

API::Node getBlobClient(boolean directCreation) {
  // BlobClient obtained through client transitions
  directCreation = false and
  result = getBlobClientTransition().getReturn()
  or
  // Direct BlobClient instantiation
  directCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // BlobClient from connection string or URL
  directCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

// Unified representation of all Azure Storage client types
API::Node getStorageClient(boolean directCreation) {
  result in [getBlobServiceClient(directCreation), getContainerClient(directCreation), getBlobClient(directCreation)]
}

// Encryption state tracking for data flow analysis
newtype EncryptionState =
  V1Encryption() or
  NoEncryption()

// Configuration for data flow analysis with encryption state tracking
private module EncryptionFlowAnalysisConfig implements DataFlow::StateConfigSig {
  class FlowState = EncryptionState;

  // Source nodes: uninitialized clients (no encryption configured)
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = NoEncryption() and
    node = getStorageClient(true).asSource()
  }

  // Barrier nodes: clients explicitly configured with v2 encryption
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(state) and
    exists(DataFlow::AttrWrite versionAttr |
      node = getStorageClient(_).getAValueReachableFromSource() and
      versionAttr.accesses(node, "encryption_version") and
      versionAttr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // Barrier for state transition when encryption is configured
    isAdditionalFlowStep(_, NoEncryption(), node, V1Encryption()) and
    state = NoEncryption()
  }

  // Flow transitions between client objects
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [getContainerClientTransition(), getBlobClientTransition()] and
      node1 = transitionCall.getObject() and
      node2 = transitionCall
    )
  }

  // State transition when encryption configuration is applied
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = NoEncryption() and
    state2 = V1Encryption() and
    exists(DataFlow::AttrWrite keyAttr |
      node1 = getStorageClient(_).getAValueReachableFromSource() and
      keyAttr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // Sink nodes: v1 encrypted blob upload operations
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = V1Encryption() and
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = getBlobClient(_).getMember("upload_blob").getACall() and
      node = uploadCall.getObject()
    )
  }

  // No restrictions on incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global data flow analysis with encryption state tracking
module EncryptionFlowAnalysis = DataFlow::GlobalWithState<EncryptionFlowAnalysisConfig>;

import EncryptionFlowAnalysis::PathGraph

// Query: Identify unsafe v1 encryption usage paths
from EncryptionFlowAnalysis::PathNode sourceNode, EncryptionFlowAnalysis::PathNode sinkNode
where EncryptionFlowAnalysis::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "Unsafe usage of v1 version of Azure Storage client-side encryption"