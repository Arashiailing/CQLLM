/**
 * @name Symmetric Encryption Algorithm Detection
 * @description Identifies implementations of symmetric encryption algorithms 
 *              in Python codebases by analyzing cryptographic libraries and their
 *              specific usage patterns across the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricAlgorithm
select symmetricAlgorithm, "Identified symmetric encryption algorithm: " + symmetricAlgorithm.getEncryptionName()