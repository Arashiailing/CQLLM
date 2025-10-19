/**
 * @name Cryptographic Hash Algorithms Detection
 * @description Identifies all potential usage of cryptographic hash algorithms
 *              across supported cryptographic libraries in Python code.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis and AST parsing
import python

// Import experimental cryptography concepts module for algorithm detection
import experimental.cryptography.Concepts

// Define the source of cryptographic hash algorithm instances
from HashAlgorithm hashAlgoInstance

// Generate query results by selecting each identified hash algorithm
// along with a formatted message describing the algorithm name
select hashAlgoInstance, "Use of algorithm " + hashAlgoInstance.getName()