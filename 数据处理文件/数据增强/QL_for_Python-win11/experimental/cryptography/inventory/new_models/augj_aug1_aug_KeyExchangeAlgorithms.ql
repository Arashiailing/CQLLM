/**
 * @name Key Exchange Algorithms Detection
 * @description Identifies cryptographic key exchange algorithm implementations across supported libraries
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

// Detect key exchange algorithm implementations
from KeyExchangeAlgorithm keyExchangeAlgo

// Report findings with algorithm identification
select keyExchangeAlgo, "Detected algorithm implementation: " + keyExchangeAlgo.getName()