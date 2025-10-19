/**
 * @name Key Derivation Algorithms
 * @description Detects usage of key derivation functions through supported 
 *              cryptographic libraries, highlighting potential quantum vulnerabilities.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic operations implementing key derivation
from KeyDerivationOperation keyDerivationInstance
where keyDerivationInstance.getAlgorithm() instanceof KeyDerivationAlgorithm
// Generate alert with algorithm-specific vulnerability context
select keyDerivationInstance,
  "Key derivation function detected: " + 
  keyDerivationInstance.getAlgorithm().(KeyDerivationAlgorithm).getKDFName() + 
  " - This cryptographic operation may have quantum vulnerabilities"