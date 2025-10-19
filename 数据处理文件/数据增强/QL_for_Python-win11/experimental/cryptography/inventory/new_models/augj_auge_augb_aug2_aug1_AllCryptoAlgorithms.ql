/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies and enumerates all cryptographic algorithm implementations within the codebase.
 *              This analysis systematically scans supported libraries to detect cryptographic
 *              algorithm usage, forming the basis for a complete Cryptographic Bill of Materials (CBOM)
 *              to evaluate quantum computing readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential modules for Python code analysis and cryptographic detection capabilities
import python
import experimental.cryptography.Concepts

// Main analysis: Identify all cryptographic algorithm implementations and generate detection messages
from CryptographicAlgorithm cryptoAlgoImpl
// Generate detailed alert message with the specific algorithm name
select cryptoAlgoImpl, "Cryptographic algorithm detected: " + cryptoAlgoImpl.getName()