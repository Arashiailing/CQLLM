/**
 * @name 未经验证的初始化向量 (IV) 或 nonce
 * @description 识别在使用块密码模式时未正确配置初始化向量或nonce的代码实例
 *              当这些关键参数来源不可信或未正确设置时，可能导致加密机制被破解
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查询目标：定位所有使用块密码模式的加密操作
// 特别关注那些IV或nonce配置存在安全隐患的实例，尤其是当这些参数可能来源于不可信输入时
from BlockMode vulnerableBlockMode
where 
    // 安全检查：验证块密码模式是否已配置适当的IV或nonce
    // 未正确配置这些参数会显著降低加密安全性，使系统容易受到攻击
    not vulnerableBlockMode.hasIVorNonce()
select 
    // 输出结果：报告存在安全风险的块密码模式实例
    vulnerableBlockMode, 
    // 提供问题描述
    "Block mode with unknown IV or Nonce configuration"