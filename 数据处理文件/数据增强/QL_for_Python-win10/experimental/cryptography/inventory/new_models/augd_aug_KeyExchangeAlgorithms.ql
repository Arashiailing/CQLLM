/**
 * @name Key Exchange Algorithms Detection
 * @description Discovers and reports all key exchange algorithm implementations in supported cryptographic libraries.
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

// Define the source of cryptographic key exchange implementations
from KeyExchangeAlgorithm cryptoKeyExchange

// Generate alert message for each identified key exchange algorithm
select cryptoKeyExchange, "Detected key exchange algorithm: " + cryptoKeyExchange.getName()