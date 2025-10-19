/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies all instances where symmetric encryption algorithms are being used
 *              within the analyzed Python codebase through supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricEncryptionInstance
select symmetricEncryptionInstance, "Use of algorithm " + symmetricEncryptionInstance.getEncryptionName()