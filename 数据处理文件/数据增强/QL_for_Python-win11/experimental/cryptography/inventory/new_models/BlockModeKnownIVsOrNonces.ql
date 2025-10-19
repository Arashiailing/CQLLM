/**
 * @name Initialization Vector (IV) or nonces
 * @description Finds all potential sources for initialization vectors (IV) or nonce used in block ciphers while using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python // 导入Python语言库，用于分析Python代码
import experimental.cryptography.Concepts // 导入实验性加密概念库，用于处理加密相关的概念和模式

// 从BlockMode算法中选择初始化向量（IV）或随机数（nonce）的来源表达式
from BlockMode alg
select alg.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
