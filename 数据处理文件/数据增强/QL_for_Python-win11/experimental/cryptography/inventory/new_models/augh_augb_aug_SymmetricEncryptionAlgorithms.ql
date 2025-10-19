/**
 * @name Symmetric Encryption Algorithms Identification
 * @description Identifies the use of symmetric encryption algorithms in Python codebases
 *              by analyzing calls to supported cryptographic libraries. This detection
 *              is crucial for assessing cryptographic agility and quantum readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricEncryption
select symmetricEncryption,
       "Use of algorithm " + symmetricEncryption.getEncryptionName()