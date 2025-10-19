/**
 * @name Quantum-Unsafe Symmetric Encryption Detection
 * @description Identifies all symmetric encryption algorithm implementations in Python codebases
 *              that may be vulnerable to quantum computing attacks. This query tracks
 *              cryptographic primitives from supported libraries to assess quantum readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       quantum-computing
 *       post-quantum-cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm quantumVulnerableAlgorithm
select quantumVulnerableAlgorithm, 
       "Quantum-vulnerable symmetric encryption detected: " + quantumVulnerableAlgorithm.getEncryptionName()