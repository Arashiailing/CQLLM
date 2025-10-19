/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic operations that utilize block cipher modes,
 *              which may be vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python语言基础库和Semmle Python安全概念库
import python
import semmle.python.Concepts

// 查询所有使用块密码模式的加密操作
from Cryptography::CryptographicOperation cryptoOperation, string blockCipherMode
where 
  // 提取加密操作所使用的块密码模式
  blockCipherMode = cryptoOperation.getBlockMode()
select 
  cryptoOperation, 
  "Detected use of block cipher mode: " + blockCipherMode