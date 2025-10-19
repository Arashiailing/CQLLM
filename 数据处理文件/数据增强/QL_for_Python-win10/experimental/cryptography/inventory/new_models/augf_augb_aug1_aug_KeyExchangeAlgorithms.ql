/**
 * @name Key Exchange Algorithms Detection
 * @description Identifies cryptographic key exchange algorithm implementations across supported libraries.
 *              These algorithms may pose security risks in quantum computing contexts.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python analysis framework for code examination
import python

// Cryptographic concepts and primitives for security analysis
import experimental.cryptography.Concepts

// Identify all cryptographic key exchange algorithm implementations
// These algorithms require security evaluation against quantum threats
from KeyExchangeAlgorithm cryptoKeyExchange

// Generate results showing each identified key exchange algorithm
// with contextual information about its cryptographic implementation
select cryptoKeyExchange, "Cryptographic key exchange algorithm detected: " + cryptoKeyExchange.getName()