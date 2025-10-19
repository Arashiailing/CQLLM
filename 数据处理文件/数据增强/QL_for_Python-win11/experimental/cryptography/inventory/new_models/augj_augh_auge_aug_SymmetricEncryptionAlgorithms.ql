/**
 * @name Quantum-Unsafe Symmetric Encryption Detection
 * @description This analysis identifies symmetric encryption algorithms in Python projects
 *              that are susceptible to quantum computing threats. By examining cryptographic
 *              implementations from standard libraries, it evaluates the codebase's preparedness
 *              for quantum attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       quantum-computing
 *       post-quantum-cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify symmetric encryption algorithms vulnerable to quantum computing attacks
from SymmetricEncryptionAlgorithm quantumUnsafeCipher

// Generate alert for each quantum-vulnerable symmetric encryption algorithm
select quantumUnsafeCipher, 
       "Quantum-vulnerable symmetric encryption detected: " + quantumUnsafeCipher.getEncryptionName()