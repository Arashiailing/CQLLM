/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic operations that utilize block cipher modes,
 *              which are considered vulnerable in the context of quantum computing.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python and Semmle libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Identify cryptographic operations and their associated block cipher modes
from Cryptography::CryptographicOperation cipherOperation, string blockModeName
where 
  // Extract the block mode used by the cryptographic operation
  blockModeName = cipherOperation.getBlockMode()
select 
  cipherOperation, 
  "Detected use of block cipher mode: " + blockModeName + " (potentially vulnerable to quantum attacks)"