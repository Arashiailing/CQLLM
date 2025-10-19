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

// Define and retrieve all asymmetric cryptographic algorithm instances
from AsymmetricAlgorithm cryptoAsymmetricAlgo

// Output detected asymmetric algorithms with descriptive messages
select cryptoAsymmetricAlgo, "Detected asymmetric algorithm: " + cryptoAsymmetricAlgo.getName()