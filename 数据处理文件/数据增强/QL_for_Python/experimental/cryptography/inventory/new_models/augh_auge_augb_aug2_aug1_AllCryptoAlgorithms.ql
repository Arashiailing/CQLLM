/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies and documents all cryptographic algorithm implementations across the codebase.
 *              This analysis scans supported libraries to detect cryptographic algorithm usage,
 *              forming the basis for a complete Cryptographic Bill of Materials (CBOM) to evaluate
 *              quantum vulnerability and readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary modules for Python code analysis and cryptographic detection
import python
import experimental.cryptography.Concepts

// Define the source of cryptographic algorithm implementations
from CryptographicAlgorithm cryptoAlgoImpl

// Generate alert message for each detected cryptographic algorithm
select cryptoAlgoImpl, "Cryptographic algorithm detected: " + cryptoAlgoImpl.getName()