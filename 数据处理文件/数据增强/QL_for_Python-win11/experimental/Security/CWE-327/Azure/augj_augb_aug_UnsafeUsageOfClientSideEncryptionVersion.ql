/**
 * 检测Azure Storage客户端加密v1版本的不安全使用。
 * @description 使用Azure Storage客户端加密的v1版本存在安全风险，可能允许攻击者解密加密数据
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
 * 获取Blob服务客户端的API节点。
 * @param isDirectCreation - 如果节点代表客户端直接创建则为true
 * @returns Blob服务客户端的API节点
 */
API::Node fetchBlobServiceClientNode(boolean isDirectCreation) {
  // 处理直接实例化BlobServiceClient的情况
  isDirectCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getReturn()
  or
  // 处理通过连接字符串创建BlobServiceClient的情况
  isDirectCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobServiceClient")
        .getMember("from_connection_string")
        .getReturn()
}

/**
 * 获取容器客户端转换调用的API节点。
 * @returns 容器客户端转换调用的API节点
 */
API::CallNode fetchContainerTransitionCall() {
  // 处理从Blob服务客户端获取容器客户端的情况
  result = fetchBlobServiceClientNode(_).getMember("get_container_client").getACall()
  or
  // 处理从Blob客户端获取容器客户端的情况
  result = fetchBlobClientNode(_).getMember("_get_container_client").getACall()
}

/**
 * 获取容器客户端的API节点。
 * @param isDirectCreation - 如果节点代表客户端直接创建则为true
 * @returns 容器客户端的API节点
 */
API::Node fetchContainerClientNode(boolean isDirectCreation) {
  // 处理从转换调用获取容器客户端的情况
  isDirectCreation = false and
  result = fetchContainerTransitionCall().getReturn()
  or
  // 处理直接实例化ContainerClient的情况
  isDirectCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getReturn()
  or
  // 处理通过连接字符串或URL创建ContainerClient的情况
  isDirectCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("ContainerClient")
        .getMember(["from_connection_string", "from_container_url"])
        .getReturn()
}

/**
 * 获取Blob客户端转换调用的API节点。
 * @returns Blob客户端转换调用的API节点
 */
API::CallNode fetchBlobTransitionCall() {
  // 处理从Blob服务或容器客户端获取Blob客户端的情况
  result = [fetchBlobServiceClientNode(_), fetchContainerClientNode(_)]
        .getMember("get_blob_client")
        .getACall()
}

/**
 * 获取Blob客户端的API节点。
 * @param isDirectCreation - 如果节点代表客户端直接创建则为true
 * @returns Blob客户端的API节点
 */
API::Node fetchBlobClientNode(boolean isDirectCreation) {
  // 处理从转换调用获取Blob客户端的情况
  isDirectCreation = false and
  result = fetchBlobTransitionCall().getReturn()
  or
  // 处理直接实例化BlobClient的情况
  isDirectCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getReturn()
  or
  // 处理通过连接字符串或URL创建BlobClient的情况
  isDirectCreation = true and
  result =
    API::moduleImport("azure")
        .getMember("storage")
        .getMember("blob")
        .getMember("BlobClient")
        .getMember(["from_connection_string", "from_blob_url"])
        .getReturn()
}

/**
 * 获取任意存储客户端API节点（Blob服务、容器或Blob）。
 * @param isDirectCreation - 如果节点代表客户端直接创建则为true
 * @returns 任意存储客户端的API节点
 */
API::Node fetchAnyStorageClientNode(boolean isDirectCreation) {
  result in [
    fetchBlobServiceClientNode(isDirectCreation),
    fetchContainerClientNode(isDirectCreation),
    fetchBlobClientNode(isDirectCreation)
  ]
}

// 定义Azure存储客户端的加密状态类型
newtype AzureEncryptionState =
  UsesV1Encryption()   // 表示正在使用v1加密
  or
  UsesNoEncryption()   // 表示未配置加密

/**
 * 跟踪Azure Blob客户端中加密状态的配置模块。
 * 实现DataFlow::StateConfigSig接口。
 */
private module AzureStorageClientConfig implements DataFlow::StateConfigSig {
  class FlowState = AzureEncryptionState;

  /**
   * 识别可能未配置加密的源节点。
   * @param dataNode - 要检查的数据流节点
   * @param flowState - 要设置的流状态
   */
  predicate isSource(DataFlow::Node dataNode, FlowState flowState) {
    flowState = UsesNoEncryption() and
    dataNode = fetchAnyStorageClientNode(true).asSource()
  }

  /**
   * 识别正确配置加密的屏障节点。
   * @param dataNode - 要检查的数据流节点
   * @param flowState - 要检查的流状态
   */
  predicate isBarrier(DataFlow::Node dataNode, FlowState flowState) {
    exists(flowState) and
    // 检测显式的v2加密配置
    exists(DataFlow::AttrWrite encryptionAttr |
      dataNode = fetchAnyStorageClientNode(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(dataNode, "encryption_version") and
      encryptionAttr.getValue().asExpr().(StringLiteral).getText() in ["'2.0'", "2.0"]
    )
    or
    // 优化：当设置了加密属性时阻止流动
    isAdditionalFlowStep(_, UsesNoEncryption(), dataNode, UsesV1Encryption()) and
    flowState = UsesNoEncryption()
  }

  /**
   * 识别客户端对象之间的额外流步骤。
   * @param sourceNode - 源节点
   * @param targetNode - 目标节点
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(DataFlow::MethodCallNode transitionCall |
      transitionCall in [fetchContainerTransitionCall(), fetchBlobTransitionCall()] and
      sourceNode = transitionCall.getObject() and
      targetNode = transitionCall
    )
  }

  /**
   * 识别流过程中的状态转换。
   * @param sourceNode - 源节点
   * @param sourceState - 源状态
   * @param targetNode - 目标节点
   * @param targetState - 目标状态
   */
  predicate isAdditionalFlowStep(
    DataFlow::Node sourceNode, FlowState sourceState, 
    DataFlow::Node targetNode, FlowState targetState
  ) {
    sourceNode = targetNode.(DataFlow::PostUpdateNode).getPreUpdateNode() and
    sourceState = UsesNoEncryption() and
    targetState = UsesV1Encryption() and
    // 检测触发v1使用的加密配置
    exists(DataFlow::AttrWrite encryptionAttr |
      sourceNode = fetchAnyStorageClientNode(_).getAValueReachableFromSource() and
      encryptionAttr.accesses(sourceNode, ["key_encryption_key", "key_resolver_function"])
    )
  }

  /**
   * 识别使用v1加密进行Blob上传的汇节点。
   * @param dataNode - 要检查的数据流节点
   * @param flowState - 要检查的流状态
   */
  predicate isSink(DataFlow::Node dataNode, FlowState flowState) {
    flowState = UsesV1Encryption() and
    // 检测Blob上传操作
    exists(DataFlow::MethodCallNode uploadCall |
      uploadCall = fetchBlobClientNode(_).getMember("upload_blob").getACall() and
      dataNode = uploadCall.getObject()
    )
  }

  // 为增量模式启用差分通知分析
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 带状态跟踪的全局数据流分析模块
module AzureStorageClientFlow = DataFlow::GlobalWithState<AzureStorageClientConfig>;

import AzureStorageClientFlow::PathGraph

/**
 * 主查询：检测不安全的v1加密使用。
 * 查找从未加密源到使用v1加密的Blob上传的路径。
 */
from AzureStorageClientFlow::PathNode source, AzureStorageClientFlow::PathNode sink
where AzureStorageClientFlow::flowPath(source, sink)
select sink, source, sink, "Azure Storage客户端加密不安全地使用了v1版本"