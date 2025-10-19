/**
 * @name Key Exchange Algorithm Identification
 * @description Identifies all cryptographic key exchange algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential Python analysis components
import python

// Import experimental cryptography primitives for analysis
import experimental.cryptography.Concepts

// Define key exchange algorithm implementations as data source
from KeyExchangeAlgorithm keyExchangeImpl

// Generate results with algorithm identification
select keyExchangeImpl, "Algorithm implementation detected: " + keyExchangeImpl.getName()