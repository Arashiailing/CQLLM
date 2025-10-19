/**
 * @name Key Exchange Algorithms Detection
 * @description Identifies and reports all cryptographic key exchange algorithm implementations
 *              across supported cryptographic libraries for quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis framework
import python

// Import experimental cryptographic concepts module
import experimental.cryptography.Concepts

// Identify cryptographic key exchange implementations
from KeyExchangeAlgorithm keyExchangeImpl

// Generate alert for each detected key exchange algorithm
select keyExchangeImpl, "Detected key exchange algorithm: " + keyExchangeImpl.getName()