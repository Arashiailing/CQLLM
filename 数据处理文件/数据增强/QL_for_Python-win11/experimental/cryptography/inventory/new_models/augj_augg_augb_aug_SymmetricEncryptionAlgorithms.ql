/**
 * @name Symmetric Encryption Algorithm Usage Identification
 * @description Identifies implementations of symmetric encryption algorithms in Python
 *              cryptographic libraries. This detection is critical for quantum readiness
 *              assessments as symmetric encryption may require increased key lengths
 *              to maintain security against quantum computing threats.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query to locate all symmetric encryption algorithm implementations
from SymmetricEncryptionAlgorithm symmetricEncryptionInstance

// Report each identified symmetric encryption algorithm with its name
select symmetricEncryptionInstance, "Detected symmetric encryption algorithm: " + symmetricEncryptionInstance.getEncryptionName()