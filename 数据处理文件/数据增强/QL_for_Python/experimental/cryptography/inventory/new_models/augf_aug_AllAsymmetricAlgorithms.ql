/**
 * @name All Asymmetric Algorithms
 * @description Identifies all potential asymmetric cryptographic algorithm implementations (RSA & ECC) 
 *              across supported cryptographic libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-asymmetric-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis
import python

// Import experimental cryptographic concepts library for algorithm detection
import experimental.cryptography.Concepts

// Define variable for asymmetric algorithm instances
from AsymmetricAlgorithm asymmetricCryptoAlgorithm

// Output algorithm instances with descriptive messages
select asymmetricCryptoAlgorithm, "Detected asymmetric algorithm: " + asymmetricCryptoAlgorithm.getName()