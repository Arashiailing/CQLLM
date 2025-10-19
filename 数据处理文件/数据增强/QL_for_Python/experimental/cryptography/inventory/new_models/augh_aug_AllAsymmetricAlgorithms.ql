/**
 * @name Comprehensive Asymmetric Cryptography Detection
 * @description Discovers all asymmetric cryptographic algorithm implementations (RSA & ECC) 
 *              across supported cryptographic libraries within the analyzed codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-asymmetric-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis
import python

// Import experimental cryptographic concepts library for algorithm identification
import experimental.cryptography.Concepts

// Define cryptographic algorithm instance variable
from AsymmetricAlgorithm asymmetricCrypto

// Generate detection results with algorithm identification
select asymmetricCrypto, "Identified asymmetric cryptographic algorithm: " + asymmetricCrypto.getName()