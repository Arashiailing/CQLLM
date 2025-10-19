/**
 * @name Signing Algorithms
 * @description Finds all potential usage of signing algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis framework
import python

// Import cryptographic concepts module for algorithm identification
import experimental.cryptography.Concepts

// Identify all signing algorithm instances in the analyzed codebase
from SigningAlgorithm signingAlgorithm

// Generate alert messages for each identified signing algorithm
select signingAlgorithm, "Use of algorithm " + signingAlgorithm.getName()