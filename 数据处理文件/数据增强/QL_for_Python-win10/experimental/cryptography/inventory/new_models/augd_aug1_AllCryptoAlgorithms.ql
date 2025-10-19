/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies and reports all instances of cryptographic algorithms 
 *              across various supported libraries and frameworks in the codebase.
 *              This query serves as a foundational analysis for cryptographic
 *              bill of materials (CBOM) generation and quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the core Python analysis module for code examination
import python
// Import experimental cryptography concepts to enable algorithm identification
import experimental.cryptography.Concepts

// Identify all cryptographic algorithm implementations in the codebase
from CryptographicAlgorithm cryptoAlgo
// Generate an alert for each detected algorithm, providing its name for identification
select cryptoAlgo, "Use of cryptographic algorithm: " + cryptoAlgo.getName()