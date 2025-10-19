/**
 * @name Block cipher mode of operation
 * @description Identifies all instances of block cipher modes in Python code
 *              by analyzing cryptographic operations from supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python analysis libraries
import python

// Cryptographic concepts and operations analysis framework
import experimental.cryptography.Concepts

// Query implementation: Identify block cipher modes
// This section retrieves all block cipher mode instances
from BlockMode cipherMode

// Result generation: Format output messages
// Each result includes the cipher mode instance and algorithm name
select cipherMode, 
       "Use of algorithm " + cipherMode.getBlockModeName()