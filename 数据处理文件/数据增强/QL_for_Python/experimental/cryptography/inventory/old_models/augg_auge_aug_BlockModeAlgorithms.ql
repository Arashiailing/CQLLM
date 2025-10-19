/**
 * @name Block cipher mode detection
 * @description Identifies cryptographic operations utilizing block cipher modes
 *              in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Define cryptographic operation and its associated block cipher mode
from Cryptography::CryptographicOperation cryptOperation, string modeIdentifier
where 
  // Extract block cipher mode from the cryptographic operation
  modeIdentifier = cryptOperation.getBlockMode()
select 
  cryptOperation, 
  "Cryptographic operation uses block cipher mode: " + modeIdentifier