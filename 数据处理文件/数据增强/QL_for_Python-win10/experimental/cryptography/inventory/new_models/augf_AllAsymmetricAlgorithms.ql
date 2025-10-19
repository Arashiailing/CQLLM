/**
 * @name Identification of All Asymmetric Cryptographic Algorithms
 * @description Detects all instances where asymmetric cryptographic algorithms (RSA & ECC) are utilized within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-asymmetric-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language module for code analysis
import python

// Import experimental cryptography concepts module for cryptographic-related analysis
import experimental.cryptography.Concepts

// Query to identify asymmetric cryptographic algorithm instances
from AsymmetricAlgorithm asymmetricCryptoAlgorithm

// Output the algorithm instance along with a descriptive message
select asymmetricCryptoAlgorithm, "Use of algorithm " + asymmetricCryptoAlgorithm.getName()