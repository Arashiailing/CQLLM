/**
 * @name Signing Algorithms
 * @description Identifies all instances where signing algorithms are utilized within the supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the Python language analysis library
import python

// Import the experimental cryptography concepts module to identify cryptographic operations and algorithms
import experimental.cryptography.Concepts

// Variable representing cryptographic signing algorithm instances in the codebase
from SigningAlgorithm signingAlgo

// Output each cryptographic signing algorithm instance along with a descriptive message
select signingAlgo, "Use of algorithm " + signingAlgo.getName()