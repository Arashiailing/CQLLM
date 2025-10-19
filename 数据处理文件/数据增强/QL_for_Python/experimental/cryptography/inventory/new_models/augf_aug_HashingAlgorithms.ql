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

// Define source variable for cryptographic hash algorithm instances
from HashAlgorithm cryptoHashInstance

// Generate query results selecting each identified hash algorithm
// with formatted message containing algorithm name
select cryptoHashInstance, "Use of algorithm " + cryptoHashInstance.getName()