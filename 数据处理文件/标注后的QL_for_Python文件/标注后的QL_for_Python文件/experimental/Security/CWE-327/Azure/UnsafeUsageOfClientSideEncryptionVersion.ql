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

// 获取Blob服务客户端的API节点
API::Node getBlobServiceClient(boolean isSource) {
  // 如果isSource为true，则返回通过模块导入路径获取的BlobServiceClient对象
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // 如果isSource为true，则返回通过连接字符串获取的BlobServiceClient对象
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

// 获取过渡到容器客户端的调用节点
API::CallNode getTransitionToContainerClient() {
  // 返回从Blob服务客户端或Blob客户端获取容器客户端的方法调用
  result = getBlobServiceClient(_).getMember("get_container_client").getACall()
  or
  result = getBlobClient(_).getMember("_get_container_client").getACall()
}

// 获取容器客户端的API节点
API::Node getContainerClient(boolean isSource) {
  // 如果isSource为false，则返回过渡到容器客户端方法调用的返回值
  isSource = false and
  result = getTransitionToContainerClient().getReturn()
  or
  // 如果isSource为true，则返回通过模块导入路径获取的ContainerClient对象
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // 如果isSource为true，则返回通过连接字符串或容器URL获取的ContainerClient对象
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

// 获取过渡到Blob客户端的调用节点
API::CallNode getTransitionToBlobClient() {
  // 返回从Blob服务客户端或容器客户端获取Blob客户端的方法调用
  result = [getBlobServiceClient(_), getContainerClient(_)].getMember("get_blob_client").getACall()
}

// 获取Blob客户端的API节点
API::Node getBlobClient(boolean isSource) {
  // 如果isSource为false，则返回过渡到Blob客户端方法调用的返回值
  isSource = false and
  result = getTransitionToBlobClient().getReturn()
  or
  // 如果isSource为true，则返回通过模块导入路径获取的BlobClient对象
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // 如果isSource为true，则返回通过连接字符串或Blob URL获取的BlobClient对象
  isSource = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

// 获取任意客户端的API节点（包括Blob服务客户端、容器客户端和Blob客户端）
API::Node anyClient(boolean isSource) {
  result in [getBlobServiceClient(isSource), getContainerClient(isSource), getBlobClient(isSource)]
}

// 定义一个新的类型TAzureFlowState，用于表示使用v1加密或不使用加密的状态
newtype TAzureFlowState =
  MkUsesV1Encryption() or
  MkUsesNoEncryption()

// 私有模块AzureBlobClientConfig实现了DataFlow::StateConfigSig接口，用于配置数据流状态
private module AzureBlobClientConfig implements DataFlow::StateConfigSig {
  class FlowState = TAzureFlowState;

  // 判断节点是否为源节点，且状态为MkUsesNoEncryption()
  predicate isSource(DataFlow::Node node, FlowState state) {
    state = MkUsesNoEncryption() and
    node = anyClient(true).asSource()
  }

  // 判断节点是否为屏障节点，即是否设置了加密版本为2.0的属性，或者是否进行了额外的流动步骤
  predicate isBarrier(DataFlow::Node node, FlowState state) {
    exists(state) and
    exists(DataFlow::AttrWrite attr |
      node = anyClient(_).getAValueReachableFromSource() and
      attr.accesses(node, "encryption_version") and
      attr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // 小优化：如果未设置加密属性，则阻止后续的数据流步骤。
    isAdditionalFlowStep(_, MkUsesNoEncryption(), node, MkUsesV1Encryption()) and
    state = MkUsesNoEncryption()
  }

  // 判断是否进行了额外的流动步骤，例如从容器客户端或Blob客户端获取对象的过程
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::MethodCallNode call |
      call in [getTransitionToContainerClient(), getTransitionToBlobClient()] and
      node1 = call.getObject() and
      node2 = call
    )
  }

  // 判断是否进行了额外的流动步骤，并且状态从MkUsesNoEncryption()变为MkUsesV1Encryption()
  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    node1 = node2.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    state1 = MkUsesNoEncryption() and
    state2 = MkUsesV1Encryption() and
    exists(DataFlow::AttrWrite attr |
      node1 = anyClient(_).getAValueReachableFromSource() and
      attr.accesses(node1, ["key_encryption_key", "key_resolver_function"])
    )
  }

  // 判断节点是否为汇点节点，且状态为MkUsesV1Encryption()，即使用了v1版本的加密上传了Blob
  predicate isSink(DataFlow::Node node, FlowState state) {
    state = MkUsesV1Encryption() and
    exists(DataFlow::MethodCallNode call |
      call = getBlobClient(_).getMember("upload_blob").getACall() and
      node = call.getObject()
    )
  }

  // 观察差异信息增量模式，这里不做任何限制
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 定义全局数据流分析模块AzureBlobClientFlow，使用AzureBlobClientConfig作为配置
module AzureBlobClientFlow = DataFlow::GlobalWithState<AzureBlobClientConfig>;

import AzureBlobClientFlow::PathGraph

// 查询语句：查找所有从源节点到汇点节点的路径，并选择汇点节点、源节点和汇点节点的信息，以及问题描述信息
from AzureBlobClientFlow::PathNode source, AzureBlobClientFlow::PathNode sink
where AzureBlobClientFlow::flowPath(source, sink)
select sink, source, sink, "Unsafe usage of v1 version of Azure Storage client-side encryption"
