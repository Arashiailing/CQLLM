/**
 * @name Cryptographic Hash Algorithms Detection
 * @description This query identifies all instances of cryptographic hash algorithms
 *              being used in Python code across supported cryptographic libraries.
 *              It helps in detecting cryptographic implementations that might need
 *              to be replaced with quantum-resistant alternatives in the future.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the Python language module which provides support for analyzing Python code
import python

// Import the experimental cryptography concepts module that contains definitions
// for various cryptographic algorithms and their properties
import experimental.cryptography.Concepts

// Identify all cryptographic hash algorithm instances in the codebase
from HashAlgorithm cryptoHashInstance

// Generate results that highlight each identified hash algorithm along with
// a descriptive message indicating its use
select cryptoHashInstance, "Use of algorithm " + cryptoHashInstance.getName()