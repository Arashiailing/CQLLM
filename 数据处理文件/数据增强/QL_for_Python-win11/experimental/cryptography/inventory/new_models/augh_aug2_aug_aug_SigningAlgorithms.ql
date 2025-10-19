/**
 * @name Cryptographic Signing Algorithm Detection
 * @description Detects all occurrences of signing algorithms being used across supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis framework for code scanning
import python

// Import experimental cryptography module providing access to cryptographic concepts and operations
import experimental.cryptography.Concepts

// Define the main query to identify cryptographic signing algorithm instances
from SigningAlgorithm signingAlgoInstance

// Generate output results: each detected signing algorithm with identification message
select signingAlgoInstance, "Use of algorithm " + signingAlgoInstance.getName()