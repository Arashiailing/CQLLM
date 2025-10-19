/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic operations that utilize block cipher modes,
 *              which may be vulnerable in quantum computing scenarios.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python and Semmle libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Query for cryptographic operations that employ block cipher modes
from Cryptography::CryptographicOperation cipherOperation, string modeName
where modeName = cipherOperation.getBlockMode()  // Extract the block cipher mode from the operation
select cipherOperation, "Use of algorithm " + modeName  // Report the operation and its associated mode