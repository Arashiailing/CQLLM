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

/*
 * 查询逻辑说明：
 * 1. 从代码中识别所有非对称密钥生成操作
 * 2. 追踪每个密钥生成操作的配置数据源
 * 3. 建立密钥生成操作与配置源之间的关联关系
 * 4. 输出检测到的非对称密钥生成信息及其配置源
 */

// 查询非对称密钥生成操作及其配置源
from AsymmetricKeyGen keyGenerationOperation,
     DataFlow::Node configurationSource
// 确保配置源与密钥生成操作相关联
where keyGenerationOperation.getKeyConfigSrc() = configurationSource
// 输出结果
select keyGenerationOperation,
  "检测到非对称密钥生成，使用算法: " + keyGenerationOperation.getAlgorithm().getName() +
    "，密钥配置源: $@", configurationSource, configurationSource.toString()