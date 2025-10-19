/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and catalogs all cryptographic algorithm implementations throughout the codebase.
 *              This analysis systematically examines supported libraries to identify any cryptographic
 *              algorithm usage, serving as a foundational component for creating a complete
 *              Cryptographic Bill of Materials (CBOM) to assess quantum readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential modules for Python code analysis and cryptographic detection capabilities
import python
import experimental.cryptography.Concepts

// Primary query logic to identify all cryptographic algorithm implementations
from CryptographicAlgorithm cryptographicOperation
// Construct detailed alert message including the specific algorithm name
select cryptographicOperation, "Cryptographic algorithm detected: " + cryptographicOperation.getName()