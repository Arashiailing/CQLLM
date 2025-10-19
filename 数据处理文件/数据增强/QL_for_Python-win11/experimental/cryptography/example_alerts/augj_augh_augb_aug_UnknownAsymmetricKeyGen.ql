/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别在非对称加密算法生成密钥时，使用了无法通过静态分析验证的密钥尺寸的安全风险
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 检索非对称密钥生成实例，其中密钥长度无法被静态分析工具确定
from AsymmetricKeyGen keyGenOp, DataFlow::Node keySizeSource, string cryptoAlgorithm
where
  // 提取密钥配置来源和加密算法名称
  keySizeSource = keyGenOp.getKeyConfigSrc() and
  cryptoAlgorithm = keyGenOp.getAlgorithm().getName() and
  // 确认密钥生成操作缺少静态可验证的密钥大小信息
  not keyGenOp.hasKeySize(keySizeSource)
select keyGenOp,
  // 构建安全警告消息，标识算法类型和配置源位置
  "算法 " + cryptoAlgorithm.toString() + " 的密钥生成过程使用了无法静态验证的密钥大小，配置源位于 $@", keySizeSource, keySizeSource.toString()