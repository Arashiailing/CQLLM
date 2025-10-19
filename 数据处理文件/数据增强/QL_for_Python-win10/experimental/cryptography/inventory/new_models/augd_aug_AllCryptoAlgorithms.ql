/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Systematically identifies all cryptographic algorithm implementations 
 *              across the codebase using supported cryptographic libraries for detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis capabilities
import python
// Import experimental cryptography detection framework
import experimental.cryptography.Concepts

// Primary query logic: Identify cryptographic algorithm implementations
from CryptographicAlgorithm algo
// Generate results with algorithm details and contextual message
select algo, "Cryptographic algorithm implementation detected: " + algo.getName()