/**
 * @name Signing Algorithms
 * @description Identifies all instances where signing algorithms are utilized within the supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis support library
import python

// Import experimental cryptography concepts module for identifying cryptographic operations and algorithms
import experimental.cryptography.Concepts

// Define variable to represent instances of signing algorithms in the codebase
from SigningAlgorithm signingAlgoInstance

// Output results: each signing algorithm instance along with its descriptive message
select signingAlgoInstance, "Use of algorithm " + signingAlgoInstance.getName()