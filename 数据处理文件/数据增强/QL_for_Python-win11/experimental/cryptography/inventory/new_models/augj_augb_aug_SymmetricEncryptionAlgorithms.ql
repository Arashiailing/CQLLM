/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies and reports the use of symmetric encryption algorithms in Python code
 *              that are implemented through supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify symmetric encryption algorithm instances
from SymmetricEncryptionAlgorithm algoInstance
where 
  // Validate that the algorithm has a defined name
  algoInstance.getEncryptionName() != ""
select 
  algoInstance, 
  // Format the result message
  "Use of algorithm " + algoInstance.getEncryptionName()