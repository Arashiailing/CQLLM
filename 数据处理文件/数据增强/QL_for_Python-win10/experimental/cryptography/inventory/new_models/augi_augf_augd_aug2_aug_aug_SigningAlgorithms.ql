/**
 * @name Cryptographic Signing Algorithms Identification
 * @description Systematically identifies all cryptographic signing algorithms 
 *              implemented across supported libraries in the codebase
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

// Define source: all cryptographic signing algorithm instances in the codebase
from SigningAlgorithm signingAlgo

// Generate result with algorithm details and descriptive message
select 
  signingAlgo, 
  "Cryptographic signing algorithm detected: " + signingAlgo.getName()