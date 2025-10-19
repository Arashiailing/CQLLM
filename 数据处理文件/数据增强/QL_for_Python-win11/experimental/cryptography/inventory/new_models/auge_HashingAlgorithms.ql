/**
 * @name Hash Algorithms
 * @description Identifies cryptographic hash algorithm usage across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Python code analysis framework
import python

// Cryptographic concepts library for algorithm identification
import experimental.cryptography.Concepts

// Identify all cryptographic hash algorithm instances
from HashAlgorithm hashAlgorithm

// Generate findings with algorithm names and security context
select hashAlgorithm, "Detected algorithm usage: " + hashAlgorithm.getName()