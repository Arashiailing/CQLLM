/**
 * @name Cryptographic Signing Algorithms Detection
 * @description Identifies all cryptographic signing algorithm usages across the codebase
 *               within supported cryptographic libraries. This query is essential for
 *               cryptographic bill of materials (CBOM) generation and quantum readiness
 *               assessment by detecting all instances where signing algorithms are utilized.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis support library
import python

// Import experimental cryptography concepts module for cryptographic operations identification
import experimental.cryptography.Concepts

// Query all signing algorithm instances
from SigningAlgorithm cryptoSigningAlgorithm

// Output results with algorithm identification
select cryptoSigningAlgorithm, "Use of algorithm " + cryptoSigningAlgorithm.getName()