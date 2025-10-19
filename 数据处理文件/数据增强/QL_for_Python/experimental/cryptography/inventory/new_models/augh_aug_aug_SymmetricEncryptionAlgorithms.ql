/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies usage of symmetric encryption algorithms in Python codebases
 *              by analyzing supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricEncryption
select symmetricEncryption, "Use of algorithm " + symmetricEncryption.getEncryptionName()