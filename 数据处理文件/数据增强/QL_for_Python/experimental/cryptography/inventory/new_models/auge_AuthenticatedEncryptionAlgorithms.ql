/**
 * @name Authenticated Encryption Algorithms
 * @description Identifies all potential implementations of authenticated encryption schemes within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/authenticated-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis
import python

// Import cryptographic concepts for encryption algorithm detection
import experimental.cryptography.Concepts

// Identify all authenticated encryption algorithm implementations
from AuthenticatedEncryptionAlgorithm authenticatedAlg

// Generate security alert for each detected algorithm
select authenticatedAlg, "Detected algorithm usage: " + authenticatedAlg.getAuthticatedEncryptionName()