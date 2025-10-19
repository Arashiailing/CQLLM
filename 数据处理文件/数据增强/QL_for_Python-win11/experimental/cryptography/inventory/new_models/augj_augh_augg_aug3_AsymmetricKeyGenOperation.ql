/**
 * @name 非对称密钥生成源追踪
 * @description 检测并追踪通过受支持库创建的非对称密钥，并分析其配置参数来源。
 *              此查询专注于非对称密钥生成过程及其配置数据流，目的是识别密钥管理
 *              中的潜在漏洞和安全风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

/*
 * 查询执行流程：
 * 1. 定位代码库中所有非对称密钥生成实例
 * 2. 分析每个密钥生成实例的配置参数来源
 * 3. 构建密钥生成实例与配置源之间的映射关系
 * 4. 报告识别到的非对称密钥生成详情及其配置源
 */

// 识别非对称密钥生成操作及其配置数据源
from AsymmetricKeyGen asymmetricKeyGen,
     DataFlow::Node configDataSource
// 建立密钥生成操作与配置源之间的关联
where asymmetricKeyGen.getKeyConfigSrc() = configDataSource
// 输出分析结果
select asymmetricKeyGen,
  "发现非对称密钥生成实例，算法类型: " + asymmetricKeyGen.getAlgorithm().getName() +
    "，配置参数来源: $@", configDataSource, configDataSource.toString()