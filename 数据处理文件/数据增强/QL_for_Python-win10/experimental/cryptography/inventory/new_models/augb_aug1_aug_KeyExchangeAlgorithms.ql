/**
 * @name Key Exchange Algorithms Detection
 * @description Discovers all cryptographic key exchange algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis framework for code examination
import python

// Import experimental cryptography concepts and primitives for security analysis
import experimental.cryptography.Concepts

// Query to identify all cryptographic key exchange algorithm implementations
// These algorithms are potential security concerns in the context of quantum computing
from KeyExchangeAlgorithm keyExchangeAlgo

// Generate results showing each identified key exchange algorithm
// with a descriptive message indicating its usage
select keyExchangeAlgo, "Use of algorithm " + keyExchangeAlgo.getName()