/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies all instances of symmetric encryption algorithms
 *              being utilized in Python codebases through supported
 *              cryptographic libraries. This analysis helps evaluate
 *              cryptographic posture for quantum readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm cryptoAlgorithmInstance
select cryptoAlgorithmInstance, 
       "Use of algorithm " + cryptoAlgorithmInstance.getEncryptionName()