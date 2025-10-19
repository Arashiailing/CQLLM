/**
 * @name Cryptographic Signing Algorithms Detection
 * @description Detects all potential cryptographic signing algorithm usages across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis support
import python

// Import experimental cryptography concepts for algorithm identification
import experimental.cryptography.Concepts

// Identify cryptographic signing algorithm instances
from SigningAlgorithm cryptoSigningInstance

// Report detected signing algorithms with contextual information
select cryptoSigningInstance, "Cryptographic signing algorithm detected: " + cryptoSigningInstance.getName()