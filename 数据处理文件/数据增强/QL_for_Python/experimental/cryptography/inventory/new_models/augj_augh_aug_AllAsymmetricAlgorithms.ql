/**
 * @name Comprehensive Asymmetric Cryptography Detection
 * @description Identifies all asymmetric cryptographic algorithm implementations (RSA & ECC) 
 *              across supported cryptographic libraries in the analyzed codebase.
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
from AsymmetricAlgorithm asymmetricAlgorithm

// Generate detection results with algorithm identification
select asymmetricAlgorithm, "Identified asymmetric cryptographic algorithm: " + asymmetricAlgorithm.getName()