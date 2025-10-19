/**
 * @name Key Exchange Algorithms
 * @description Identifies all implementations of key exchange algorithms within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis framework
import python

// Import experimental cryptographic concepts module
import experimental.cryptography.Concepts

// Define data source: key exchange algorithm implementations
from KeyExchangeAlgorithm keyExchangeAlgorithm

// Generate output with algorithm identification
select keyExchangeAlgorithm, "Use of algorithm " + keyExchangeAlgorithm.getName()