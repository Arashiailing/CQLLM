/**
 * @name 块密码模式缺少初始化向量或nonce配置
 * @description 检测在加密操作中使用块密码模式时，未正确设置初始化向量(IV)或nonce的情况。
 *              当这些关键参数来源不可信或未配置时，可能导致加密强度降低和安全漏洞。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询范围：所有块密码模式实例
from BlockMode blockCipherInstance
// 应用过滤条件：识别未配置IV或nonce的情况
where not blockCipherInstance.hasIVorNonce()
// 输出结果：问题实例及相应的安全风险描述
select blockCipherInstance, "Block mode with unknown IV or Nonce configuration"