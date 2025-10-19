/**
 * @name Key Exchange Algorithm Detection
 * @description Identifies cryptographic key exchange algorithm implementations across supported libraries for quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the core Python analysis framework for AST and data flow analysis
import python

// Import experimental cryptography concept definitions for algorithm classification
import experimental.cryptography.Concepts

// Query to identify all cryptographic key exchange algorithm implementations
// This helps in assessing quantum readiness by identifying potentially vulnerable algorithms
from KeyExchangeAlgorithm keyExchangeImpl
select keyExchangeImpl, "Algorithm implementation detected: " + keyExchangeImpl.getName()