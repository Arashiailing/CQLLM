/**
 * @name Cryptographic Hash Algorithms Detection
 * @description This query identifies all instances of cryptographic hash algorithms
 *              usage in Python code across supported cryptographic libraries.
 *              The detection is crucial for identifying cryptographic implementations
 *              that may need to be replaced with quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary modules for Python AST parsing and cryptographic concepts
import python
import experimental.cryptography.Concepts

// Define source: Find all cryptographic hash algorithm instances in the codebase
from HashAlgorithm cryptoHashInstance

// Generate result: For each identified hash algorithm, output the instance
// and a descriptive message including the algorithm name
select cryptoHashInstance, "Use of algorithm " + cryptoHashInstance.getName()