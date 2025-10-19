/**
 * @name Cryptographic Signing Algorithms Identification
 * @description Discovers and reports all instances of cryptographic signing algorithms 
 *              utilized within the analyzed codebase across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis capabilities
import python

// Import experimental cryptography module providing concepts for cryptographic operations
import experimental.cryptography.Concepts

// Define the source for cryptographic signing algorithms present in the code
from SigningAlgorithm cryptoSigningAlgorithm

// Construct the result output with algorithm identification and descriptive information
select cryptoSigningAlgorithm, "Identified cryptographic signing algorithm: " + cryptoSigningAlgorithm.getName()