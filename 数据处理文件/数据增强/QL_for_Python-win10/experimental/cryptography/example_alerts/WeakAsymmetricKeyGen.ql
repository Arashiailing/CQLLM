/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * This query detects the use of weak asymmetric key sizes (less than 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 从 AsymmetricKeyGen 操作中获取配置源、密钥大小和算法名称
from AsymmetricKeyGen op, DataFlow::Node configSrc, int keySize, string algName
where
  // 获取配置源的密钥大小
  keySize = op.getKeySizeInBits(configSrc) and
  // 检查密钥大小是否小于2048位
  keySize < 2048 and
  // 获取算法名称
  algName = op.getAlgorithm().getName() and
  // 确保算法不是椭圆曲线算法
  not isEllipticCurveAlgorithm(algName, _)
select op,
  // 选择操作，并生成警告信息，包括使用的弱密钥大小和算法名称
  "Use of weak asymmetric key size (int bits)" + keySize.toString() + " for algorithm " +
    algName.toString() + " at config source $@", configSrc, configSrc.toString()
