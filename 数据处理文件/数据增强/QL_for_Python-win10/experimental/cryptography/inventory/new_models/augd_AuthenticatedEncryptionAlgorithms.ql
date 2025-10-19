/**
 * @name Authenticated Encryption Algorithms Detection
 * @description Identifies potential usage of authenticated encryption schemes within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/authenticated-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python module for code analysis capabilities
import python

// Import experimental cryptography concepts for handling cryptographic algorithms and schemes
import experimental.cryptography.Concepts

// Define source of authenticated encryption algorithm instances
from AuthenticatedEncryptionAlgorithm encryptionScheme

// Generate security alert for each detected authenticated encryption algorithm
select encryptionScheme, "Use of algorithm " + encryptionScheme.getAuthticatedEncryptionName()