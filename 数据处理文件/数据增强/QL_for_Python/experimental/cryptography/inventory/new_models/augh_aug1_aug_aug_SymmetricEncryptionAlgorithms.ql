/**
 * @name Symmetric Encryption Algorithm Identification
 * @description Detects symmetric encryption algorithm implementations in Python codebases
 *              by analyzing cryptographic library usage patterns and supported algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm detectedAlgorithm
select detectedAlgorithm,
       "Identified algorithm implementation: " + detectedAlgorithm.getEncryptionName()