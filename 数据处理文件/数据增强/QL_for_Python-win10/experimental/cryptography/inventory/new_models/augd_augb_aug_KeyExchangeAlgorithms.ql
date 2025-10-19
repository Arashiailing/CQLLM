/**
 * @name Key Exchange Algorithms Detection
 * @description Identifies all key exchange algorithm implementations in supported cryptographic libraries.
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

// Source: cryptographic key exchange algorithm implementations
from KeyExchangeAlgorithm keyExchangeAlgo

// Result: algorithm identification with security alert message
select keyExchangeAlgo, "Use of algorithm " + keyExchangeAlgo.getName()