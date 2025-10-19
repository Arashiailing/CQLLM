/**
 * @name Block cipher mode detection
 * @description Identifies cryptographic operations that utilize block cipher modes
 *              within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their associated block cipher modes
from Cryptography::CryptographicOperation cryptOperation, string blockMode
where 
  // Derive the block cipher mode from the cryptographic operation
  blockMode = cryptOperation.getBlockMode()
select 
  cryptOperation, 
  "Cryptographic operation uses block cipher mode: " + blockMode