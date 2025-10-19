/**
 * @name Block cipher mode of operation
 * @description Detects cryptographic block cipher modes in Python code
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

// Data source: Identify all block cipher mode implementations
// This section captures cryptographic operations utilizing block cipher modes
from BlockMode blockModeInstance

// Result generation: Format output messages
// Each result includes the cipher mode instance and its algorithm identifier
select blockModeInstance, 
       "Use of algorithm " + blockModeInstance.getBlockModeName()