/**
 * @name Elliptic Curve Algorithms
 * @description Finds all potential usage of elliptic curve algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库
import python
// 导入实验性的加密概念库
import experimental.cryptography.Concepts

// 从EllipticCurveAlgorithm类中选择算法实例alg
from EllipticCurveAlgorithm alg
// 选择alg以及一个字符串，该字符串包含算法名称和密钥大小（以位为单位）
select alg,
  "Use of algorithm " + alg.getCurveName() + " with key size (in bits) " +
    alg.getCurveBitSize().toString()
