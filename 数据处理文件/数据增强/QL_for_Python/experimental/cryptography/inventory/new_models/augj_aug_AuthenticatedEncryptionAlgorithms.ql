/**
 * @name Authenticated Encryption Algorithms
 * @description Identifies all authenticated encryption implementations within supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/authenticated-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis framework
import python

// Import experimental cryptography concepts for encryption analysis
import experimental.cryptography.Concepts

// Identify authenticated encryption algorithm implementations
from AuthenticatedEncryptionAlgorithm authenticatedEncryption

// Generate alert with algorithm implementation details
select authenticatedEncryption, "Algorithm implementation detected: " + authenticatedEncryption.getAuthticatedEncryptionName()