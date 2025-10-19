/**
 * @name Key Exchange Algorithm Detection
 * @description Detects cryptographic key exchange algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis framework
import python

// Import experimental cryptography concept definitions
import experimental.cryptography.Concepts

// Identify key exchange algorithm implementations
from KeyExchangeAlgorithm cryptoKeyExchange
select cryptoKeyExchange, "Algorithm implementation detected: " + cryptoKeyExchange.getName()