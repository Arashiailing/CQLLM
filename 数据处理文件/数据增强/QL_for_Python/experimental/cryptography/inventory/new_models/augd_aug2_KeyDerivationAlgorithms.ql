/**
 * @name Key Derivation Algorithms Detection
 * @description This query identifies the usage of cryptographic key derivation functions within supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify key derivation operations in the codebase
from KeyDerivationOperation kdfOperation
// Generate alert message containing algorithm information
select kdfOperation,
  "Key derivation function detected: " + kdfOperation.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()