/**
 * @name Key Exchange Algorithms
 * @description Identifies all implementations of key exchange algorithms within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the Python analysis framework to enable code scanning
import python

// Import experimental cryptographic concepts for identifying key exchange algorithms
import experimental.cryptography.Concepts

// Source: All key exchange algorithm implementations in the codebase
from KeyExchangeAlgorithm keyExchangeImpl

// Result: Report each key exchange algorithm implementation with its name
select keyExchangeImpl, "Use of algorithm " + keyExchangeImpl.getName()