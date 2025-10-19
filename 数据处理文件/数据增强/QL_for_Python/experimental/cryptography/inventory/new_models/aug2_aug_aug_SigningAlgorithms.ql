/**
 * @name Signing Algorithms
 * @description Identifies all instances where signing algorithms are utilized within the supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis support library
import python

// Import experimental cryptography concepts module for identifying cryptographic operations and algorithms
import experimental.cryptography.Concepts

// Define variable representing cryptographic signing algorithm instances in the codebase
from SigningAlgorithm cryptoSigningAlgorithm

// Output results: each cryptographic signing algorithm instance with its descriptive message
select cryptoSigningAlgorithm, "Use of algorithm " + cryptoSigningAlgorithm.getName()