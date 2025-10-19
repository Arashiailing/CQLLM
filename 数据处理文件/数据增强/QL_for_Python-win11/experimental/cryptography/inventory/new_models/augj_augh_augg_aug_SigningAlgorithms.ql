/**
 * @name Quantum-Readiness: Cryptographic Signing Algorithms Detection
 * @description Identifies and reports all cryptographic signing algorithm implementations that may be vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis capabilities
import python

// Import experimental cryptography framework for algorithm detection
import experimental.cryptography.Concepts

// Define the source of cryptographic signing algorithm instances
from SigningAlgorithm signingAlgorithmImpl

// Construct and format the alert message with algorithm details
select signingAlgorithmImpl, 
       "Potential quantum-vulnerable cryptographic signing algorithm found: " + 
       signingAlgorithmImpl.getName()