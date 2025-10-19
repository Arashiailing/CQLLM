/**
 * @name Signing Algorithms Detection
 * @description Identifies cryptographic signing algorithm usage across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language analysis capabilities
import python

// Import experimental cryptography concepts for algorithm identification
import experimental.cryptography.Concepts

// Define variable representing cryptographic signing algorithm instances
from SigningAlgorithm cryptoSigningInstance

// Output algorithm instances with descriptive messages
select cryptoSigningInstance, 
       "Algorithm usage detected: " + cryptoSigningInstance.getName()