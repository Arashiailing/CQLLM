/**
 * @name Comprehensive Asymmetric Cryptographic Algorithm Detection
 * @description Detects and reports all occurrences of asymmetric cryptographic algorithms
 *              (including RSA and Elliptic Curve Cryptography) across supported
 *              cryptographic libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-asymmetric-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python module for code parsing and analysis
import python

// Import experimental cryptography concepts for cryptographic-related analysis
import experimental.cryptography.Concepts

// Identify all asymmetric cryptographic algorithm instances in the codebase
from AsymmetricAlgorithm asymmetricAlgoInstance

// Generate results showing each asymmetric algorithm instance with descriptive information
select asymmetricAlgoInstance, 
       "Detected usage of asymmetric algorithm: " + asymmetricAlgoInstance.getName()