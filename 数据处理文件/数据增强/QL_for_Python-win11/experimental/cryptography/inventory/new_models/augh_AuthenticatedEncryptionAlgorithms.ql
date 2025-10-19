/**
 * @name Authenticated Encryption Algorithms
 * @description Identifies potential usage of authenticated encryption schemes in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/authenticated-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis
import python

// Import experimental cryptography concepts for cryptographic algorithm handling
import experimental.cryptography.Concepts

// Select all instances of authenticated encryption algorithms
from AuthenticatedEncryptionAlgorithm authenticatedEncryption

// Generate alert for each detected authenticated encryption algorithm
select authenticatedEncryption, "Detected algorithm usage: " + authenticatedEncryption.getAuthticatedEncryptionName()