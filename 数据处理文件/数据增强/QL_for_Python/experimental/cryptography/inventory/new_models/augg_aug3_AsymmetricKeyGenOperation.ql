/**
 * @name 非对称密钥生成源识别
 * @description 识别通过受支持库生成的非对称密钥，并追踪其配置来源。
 *              本查询分析非对称密钥生成操作及其配置数据流，旨在发现密钥管理
 *              潜在问题和安全风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义非对称密钥生成操作变量
from AsymmetricKeyGen asymKeyGen,
     // 定义密钥配置源变量
     DataFlow::Node configOrigin
// 筛选条件：配置源与密钥生成操作关联
where asymKeyGen.getKeyConfigSrc() = configOrigin
select asymKeyGen,
  "检测到非对称密钥生成，使用算法: " + asymKeyGen.getAlgorithm().getName() +
    "，密钥配置源: $@", configOrigin, configOrigin.toString()