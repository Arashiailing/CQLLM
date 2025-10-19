/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Locates all occurrences of cryptographic hash algorithm usage across the analyzed codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the base Python analysis module
import python

// Import experimental cryptography concepts for identifying hash algorithms
import experimental.cryptography.Concepts

// Define the source of cryptographic hash algorithm instances
from HashAlgorithm hashInstance

// Output results for each detected hash algorithm instance
select hashInstance, "Detected usage of cryptographic hash algorithm: " + hashInstance.getName()