/**
 * @name Block cipher mode of operation
 * @description Finds all potential block cipher modes of operations using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库和Semmle Python概念库
import python
import semmle.python.Concepts

// 从Cryptography库中选择加密操作和算法名称
from Cryptography::CryptographicOperation operation, string algName
where algName = operation.getBlockMode() // 获取加密操作的块模式
select operation, "Use of algorithm " + algName // 选择操作和使用算法的描述
