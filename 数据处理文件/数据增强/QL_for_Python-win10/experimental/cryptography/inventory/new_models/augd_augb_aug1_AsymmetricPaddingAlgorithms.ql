/**
 * @name Asymmetric Cryptography Padding Scheme Detection
 * @description This query identifies all padding schemes used in asymmetric cryptographic algorithms,
 *              which is crucial for quantum readiness assessment in cryptographic implementations.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 *       quantum-readiness
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称加密算法中使用的填充方案并输出结果
from AsymmetricPadding paddingScheme
select paddingScheme, "Detected asymmetric padding scheme: " + paddingScheme.getPaddingName()