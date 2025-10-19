/**
 * @name Key Exchange Algorithms Detection
 * @description Discovers all cryptographic key exchange algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python analysis components
import python

// Import experimental cryptography primitives for analysis
import experimental.cryptography.Concepts

// Identify all key exchange algorithm implementations as data source
from KeyExchangeAlgorithm cryptoKeyExchange

// Format and output results with algorithm identification
select cryptoKeyExchange, "Use of algorithm " + cryptoKeyExchange.getName()