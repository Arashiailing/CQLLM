/**
 * @name Cryptographic Signing Algorithms Detection
 * @description Identifies all potential usages of cryptographic signing algorithms
 *              within supported cryptographic libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python module for analyzing Python source code
import python

// Import experimental cryptography concepts for handling cryptographic operations
import experimental.cryptography.Concepts

// Select all instances of signing algorithms from the SigningAlgorithm class
from SigningAlgorithm cryptoAlgorithm

// Query statement: select the algorithm instance and its name with a descriptive prefix
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getName()