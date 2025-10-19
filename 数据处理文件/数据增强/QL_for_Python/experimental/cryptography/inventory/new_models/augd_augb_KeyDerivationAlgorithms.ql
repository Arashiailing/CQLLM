/**
 * @name Quantum Vulnerable Key Derivation Functions
 * @description Detects cryptographic operations using key derivation algorithms
 *              that may be vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify key derivation operations with quantum vulnerability risks
from KeyDerivationOperation kdfOp, KeyDerivationAlgorithm algo
where algo = kdfOp.getAlgorithm()
select kdfOp,
  "Quantum-vulnerable key derivation detected: " + 
  algo.getKDFName() + 
  " - Consider quantum-resistant alternatives"