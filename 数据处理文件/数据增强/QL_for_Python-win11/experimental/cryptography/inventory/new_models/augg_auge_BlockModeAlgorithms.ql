/**
 * @name Block cipher mode of operation
 * @description Identifies all instances of block cipher modes being used in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis
import python

// Import experimental cryptography concepts for cryptographic operation analysis
import experimental.cryptography.Concepts

// Find all block cipher mode implementations
from BlockMode blockModeInstance

// Generate alert for each detected block cipher mode with algorithm name
select blockModeInstance, "Use of algorithm " + blockModeInstance.getBlockModeName()