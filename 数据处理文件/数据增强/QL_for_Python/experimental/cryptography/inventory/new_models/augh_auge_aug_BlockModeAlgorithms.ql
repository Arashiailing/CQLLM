/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic block cipher modes in Python code
 *              by analyzing operations from supported cryptographic libraries.
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

// Data source: Retrieve all block cipher mode instances
// This section collects cryptographic operations implementing block cipher modes
from BlockMode blockCipherMode

// Result formatting: Generate output messages
// Each result contains the cipher mode instance and its algorithm identifier
select blockCipherMode, 
       "Use of algorithm " + blockCipherMode.getBlockModeName()