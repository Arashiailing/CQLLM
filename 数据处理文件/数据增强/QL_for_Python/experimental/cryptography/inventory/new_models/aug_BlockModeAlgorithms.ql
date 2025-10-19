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

// Query block: Retrieve all block cipher mode implementations
from BlockMode blockModeInstance

// Results generation: Report detected modes with descriptive messages
select blockModeInstance, 
       "Use of algorithm " + blockModeInstance.getBlockModeName()