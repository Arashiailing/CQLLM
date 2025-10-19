/**
 * @name Key Exchange Algorithms Detection
 * @description Identifies cryptographic key exchange algorithm usage across supported libraries for quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python analysis components
import python

// Import experimental cryptography primitives
import experimental.cryptography.Concepts

// Query to locate and report key exchange algorithm implementations
from KeyExchangeAlgorithm keyExchangeMethod
select keyExchangeMethod, "Use of algorithm " + keyExchangeMethod.getName()