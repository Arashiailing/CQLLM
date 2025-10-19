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

// Import core Python analysis libraries for code examination
import python

// Import cryptographic concepts and operations analysis framework
import experimental.cryptography.Concepts

// Main query logic: Identify all instances of block cipher modes
// This section collects all occurrences of block cipher modes in the codebase
from BlockMode blockCipherModeInstance

// Generate results with formatted messages
// Each result includes the cipher mode instance and its corresponding algorithm name
select blockCipherModeInstance, 
       "Use of algorithm " + blockCipherModeInstance.getBlockModeName()