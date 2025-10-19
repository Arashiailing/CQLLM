/**
 * @name Symmetric Encryption Algorithm Usage Detection
 * @description This query identifies all occurrences of symmetric encryption algorithms
 *              being utilized in the Python codebase through supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricAlgorithmInstance
select symmetricAlgorithmInstance, 
       "Use of algorithm " + symmetricAlgorithmInstance.getEncryptionName()