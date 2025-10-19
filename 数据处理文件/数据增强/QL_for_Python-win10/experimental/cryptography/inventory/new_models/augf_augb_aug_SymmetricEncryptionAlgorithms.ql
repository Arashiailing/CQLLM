/**
 * @name Symmetric Encryption Algorithm Usage Detection
 * @description Identifies the use of symmetric encryption algorithms within Python codebases,
 *              specifically targeting those provided by supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricEncryptionAlgorithm
select symmetricEncryptionAlgorithm, "Use of algorithm " + symmetricEncryptionAlgorithm.getEncryptionName()