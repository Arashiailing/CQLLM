/**
 * @name Symmetric Encryption Algorithm Identification
 * @description Detects implementations of symmetric encryption algorithms within Python codebases
 *              by examining cryptographic library usage patterns and supported algorithm types.
 *              This query helps identify cryptographic components for CBOM (Cryptographic Bill of Materials) analysis.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricCipher
select symmetricCipher, "Identified symmetric encryption algorithm: " + symmetricCipher.getEncryptionName()