/**
 * @name Key Derivation Algorithms Detection
 * @description This query identifies the use of cryptographic key derivation functions within
 *              supported libraries. Such identification is vital for evaluating quantum readiness
 *              of cryptographic systems, since specific key derivation techniques could be
 *              susceptible to quantum computing threats.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Detection of cryptographic key derivation operations
// These operations are critical for security evaluation in the quantum computing era
from KeyDerivationOperation keyDerivationFunc
where exists(keyDerivationFunc.getAlgorithm().(KeyDerivationAlgorithm))
select keyDerivationFunc,
  "Detected key derivation function: " + 
  keyDerivationFunc.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()