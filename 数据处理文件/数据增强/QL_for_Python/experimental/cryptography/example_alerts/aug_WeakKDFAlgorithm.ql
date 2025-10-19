/**
 * @name Weak KDF algorithm.
 * @description This query identifies the use of weak or unapproved key derivation functions (KDFs) in Python code.
 *              Approved KDF algorithms must be one of the following:
 *              ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "CONCATKDF", "CONCATKDFHASH"]
 * @assumption The value being used to derive a key (either a key or a password) is correct for the algorithm 
 *             (i.e., a key is used for KBKDF and a password for PBKDF).
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性加密概念库，用于处理加密相关的概念和操作

// 查找所有使用非批准密钥派生算法的操作
from KeyDerivationAlgorithm keyDerivationOp
where
  not keyDerivationOp.getKDFName() = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH",
    "CONCATKDFHMAC"
  ]
select keyDerivationOp, "Use of unapproved, weak, or unknown key derivation algorithm or API."  // 选择使用了未经批准、弱或未知的密钥派生函数算法或API的操作