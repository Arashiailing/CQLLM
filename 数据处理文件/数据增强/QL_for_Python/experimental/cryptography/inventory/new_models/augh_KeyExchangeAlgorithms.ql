/**
 * @name Quantum-Vulnerable Key Exchange Detection
 * @description Identifies all implementations of key exchange algorithms that may be vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis framework
import python

// Import experimental cryptography concepts for cryptographic primitive analysis
import experimental.cryptography.Concepts

// Identify all key exchange algorithm implementations
from KeyExchangeAlgorithm vulnerableKeyExchange

// Generate alert for each vulnerable key exchange algorithm
select vulnerableKeyExchange, "Quantum-vulnerable key exchange algorithm detected: " + vulnerableKeyExchange.getName()