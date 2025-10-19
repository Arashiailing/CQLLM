/**
 * @name Detection of Authenticated Encryption Algorithms
 * @description This query identifies and reports all authenticated encryption algorithm implementations present in supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/authenticated-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required modules for Python code analysis and cryptographic concepts examination
import python
import experimental.cryptography.Concepts

// Identify authenticated encryption algorithm implementations and generate corresponding alerts
from AuthenticatedEncryptionAlgorithm authEncAlgo
select authEncAlgo, "Detected authenticated encryption algorithm: " + authEncAlgo.getAuthticatedEncryptionName()