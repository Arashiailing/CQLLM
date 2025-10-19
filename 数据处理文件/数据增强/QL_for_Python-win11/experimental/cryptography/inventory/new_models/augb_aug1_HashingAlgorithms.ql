/**
 * @name Cryptographic Hash Algorithm Usage
 * @description Identifies all instances where cryptographic hash algorithms are utilized within supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python modules for code analysis
import python

// Import experimental cryptography concepts for algorithm identification
import experimental.cryptography.Concepts

// Identify all cryptographic hash algorithm instances in the codebase
from HashAlgorithm hashAlgorithmInstance

// Generate alert for each identified hash algorithm
select hashAlgorithmInstance, "Detected usage of cryptographic hash algorithm: " + hashAlgorithmInstance.getName()