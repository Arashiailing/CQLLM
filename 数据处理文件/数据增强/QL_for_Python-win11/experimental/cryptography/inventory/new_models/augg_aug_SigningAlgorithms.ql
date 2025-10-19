/**
 * @name Signing Algorithms
 * @description Identifies all potential usages of cryptographic signing algorithms within supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis support
import python

// Import experimental cryptography concepts module for identifying cryptographic operations and algorithms
import experimental.cryptography.Concepts

// Define a variable representing instances of signing algorithms
from SigningAlgorithm signingAlgoInstance

// Output results: signing algorithm instances along with their descriptive information
select signingAlgoInstance, "Use of algorithm " + signingAlgoInstance.getName()