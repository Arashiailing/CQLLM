/**
 * @name Comprehensive Cryptographic Algorithm Identification
 * @description Systematically identifies and catalogs all cryptographic algorithm implementations
 *              across the codebase using supported cryptographic libraries for thorough detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python analysis functionalities
import python

// Import experimental utilities for cryptography detection
import experimental.cryptography.Concepts

// Specify the source for identifying cryptographic algorithms
from CryptographicAlgorithm cryptoAlgo

// Produce results including algorithm identification details
select cryptoAlgo, 
       "Cryptographic algorithm" + " implementation detected: " + cryptoAlgo.getName()