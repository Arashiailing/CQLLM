/**
 * @name Cryptographic Hash Algorithms Detection
 * @description Identifies all potential usage of cryptographic hash algorithms
 *              across supported cryptographic libraries in Python code.
 *              This detection helps identify cryptographic implementations
 *              that may require quantum-resistant alternatives.
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

// Source definition: all cryptographic hash algorithm instances in the codebase
from HashAlgorithm cryptoHashInstance

// Result generation: select each identified hash algorithm with descriptive message
select cryptoHashInstance, "Use of algorithm " + cryptoHashInstance.getName()