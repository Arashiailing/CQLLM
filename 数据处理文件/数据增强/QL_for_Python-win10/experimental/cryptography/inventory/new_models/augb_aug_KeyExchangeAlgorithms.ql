/**
 * @name Key Exchange Algorithms
 * @description Detects all key exchange algorithm implementations in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the Python analysis framework
import python

// Import the experimental cryptographic concepts module
import experimental.cryptography.Concepts

// Data source: key exchange algorithm implementations
from KeyExchangeAlgorithm algorithm

// Output: algorithm identification and alert message
select algorithm, "Use of algorithm " + algorithm.getName()