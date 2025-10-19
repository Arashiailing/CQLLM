/**
 * @name All Asymmetric Algorithms
 * @description Identifies all instances of asymmetric cryptographic algorithms (RSA & ECC) 
 *              usage across supported cryptographic libraries.
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

// Query to find all asymmetric algorithm instances
from AsymmetricAlgorithm asymmetricCryptoAlgorithm

// Output each asymmetric algorithm instance with its name description
select asymmetricCryptoAlgorithm, 
       "Use of algorithm " + asymmetricCryptoAlgorithm.getName()