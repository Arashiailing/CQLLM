/**
 * @name 未知初始化向量 (IV) 或 nonce
 * @description 识别块密码操作中缺少初始化向量或nonce配置的安全隐患
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有使用块密码模式的加密操作
from BlockMode insecureBlockMode
where 
    // 检查块密码模式是否缺少必要的初始化向量或nonce配置
    not insecureBlockMode.hasIVorNonce()
select 
    // 返回存在安全风险的块模式实例
    insecureBlockMode, 
    // 描述检测到的安全问题
    "Block mode with unknown IV or Nonce configuration"