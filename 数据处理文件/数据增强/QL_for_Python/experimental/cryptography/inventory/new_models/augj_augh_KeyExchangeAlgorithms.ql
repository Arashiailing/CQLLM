/**
 * @name Quantum-Unsafe Key Exchange Detection
 * @description Detects all code instances implementing key exchange protocols that are susceptible to quantum computing threats.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the core Python analysis framework
import python

// Import experimental cryptography module for cryptographic primitive identification
import experimental.cryptography.Concepts

// Locate all key exchange algorithm implementations
from KeyExchangeAlgorithm quantumUnsafeKeyExchange

// Report findings for each quantum-vulnerable key exchange algorithm
select quantumUnsafeKeyExchange, "Quantum-unsafe key exchange algorithm found: " + quantumUnsafeKeyExchange.getName()