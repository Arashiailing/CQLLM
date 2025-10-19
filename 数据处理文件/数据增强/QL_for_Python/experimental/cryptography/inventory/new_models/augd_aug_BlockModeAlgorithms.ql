/**
 * @name Block Cipher Mode Detection
 * @description This query identifies all occurrences of block cipher modes in Python codebases
 *              by examining cryptographic operations across supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python analysis capabilities
import python

// Import cryptographic concepts and operations analysis framework
import experimental.cryptography.Concepts

// Query logic: Fetch all block cipher mode implementations
from BlockMode cipherMode

// Output generation: Display detected modes with informative messages
select cipherMode, 
       "Detected algorithm: " + cipherMode.getBlockModeName()