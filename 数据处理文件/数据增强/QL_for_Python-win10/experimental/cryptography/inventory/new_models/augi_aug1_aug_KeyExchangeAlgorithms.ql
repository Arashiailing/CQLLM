/**
 * @name Key Exchange Algorithms Identification
 * @description Discovers all cryptographic key exchange algorithm implementations across supported libraries.
 *              This query identifies algorithm usage for cryptographic bill of materials (CBOM) analysis.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis components
import python

// Import experimental cryptography primitives for security analysis
import experimental.cryptography.Concepts

// Identify key exchange algorithm implementations
from KeyExchangeAlgorithm keyExchangeAlgorithm

// Format results with algorithm identification details
select keyExchangeAlgorithm, 
       "Use of algorithm " + keyExchangeAlgorithm.getName()