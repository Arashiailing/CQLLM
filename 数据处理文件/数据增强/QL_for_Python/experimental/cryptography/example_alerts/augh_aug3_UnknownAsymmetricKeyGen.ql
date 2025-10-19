/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别在非对称密钥生成过程中，密钥大小无法通过静态分析验证的安全风险
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 定义查询变量：密钥生成操作、配置源和算法名称
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSource, string cryptoAlgorithm
where
  // 获取密钥生成操作的配置源
  configSource = keyGenOperation.getKeyConfigSrc() and
  // 获取算法名称
  cryptoAlgorithm = keyGenOperation.getAlgorithm().getName() and
  // 验证密钥大小是否无法静态确定
  not keyGenOperation.hasKeySize(configSource)
select keyGenOperation,
  // 构建警告消息，指出算法和配置源的问题
  "算法 " + cryptoAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configSource, configSource.toString()