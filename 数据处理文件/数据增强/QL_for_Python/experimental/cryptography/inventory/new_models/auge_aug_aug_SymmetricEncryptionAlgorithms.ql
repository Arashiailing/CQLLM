/**
 * @name Identification of Symmetric Encryption Algorithms
 * @description Identifies instances where symmetric encryption algorithms are utilized
 *              within Python codebases, focusing on recognized cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricCipher
select symmetricCipher, "Use of algorithm " + symmetricCipher.getEncryptionName()