/**
 * @name Symmetric Encryption Algorithm Usage Identification
 * @description Identifies implementations of symmetric encryption algorithms in Python
 *              cryptographic libraries, highlighting potential quantum vulnerability.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify symmetric encryption algorithm instances
from SymmetricEncryptionAlgorithm symmetricCipher
// Generate alert with algorithm name
select symmetricCipher, "Detected symmetric encryption algorithm: " + symmetricCipher.getEncryptionName()