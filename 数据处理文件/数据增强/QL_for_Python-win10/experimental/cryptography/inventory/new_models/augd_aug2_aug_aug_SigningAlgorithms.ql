/**
 * @name Signing Algorithms Detection
 * @description Identifies all cryptographic signing algorithm usages across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis support library
import python

// Import experimental cryptography concepts module for cryptographic operations and algorithms
import experimental.cryptography.Concepts

// Retrieve all signing algorithm instances in the codebase
from SigningAlgorithm signingAlgorithmInstance

// Generate results with algorithm identification and descriptive message
select signingAlgorithmInstance, "Algorithm detected: " + signingAlgorithmInstance.getName()