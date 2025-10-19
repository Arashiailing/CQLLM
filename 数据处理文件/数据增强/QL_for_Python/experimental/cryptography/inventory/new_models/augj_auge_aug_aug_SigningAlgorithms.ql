/**
 * @name Cryptographic Signing Algorithms Detection
 * @description Discovers all cryptographic signing algorithm implementations throughout the codebase
 *               within supported cryptographic libraries. This analysis is crucial for
 *               cryptographic bill of materials (CBOM) generation and quantum computing readiness
 *               evaluation by identifying every occurrence where signing algorithms are employed.
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

// Define source for cryptographic signing algorithm instances
from SigningAlgorithm signatureAlgorithm

// Generate results with algorithm identification details
select signatureAlgorithm, "Use of algorithm " + signatureAlgorithm.getName()