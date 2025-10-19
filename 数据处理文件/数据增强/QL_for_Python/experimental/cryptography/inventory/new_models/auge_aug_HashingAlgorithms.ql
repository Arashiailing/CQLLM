/**
 * @name Detection of Cryptographic Hash Algorithms
 * @description This query identifies all instances where cryptographic hash algorithms
 *              are utilized within Python code, covering multiple supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python language modules for code analysis and AST parsing
import python

// Import experimental cryptography concepts module to facilitate algorithm detection
import experimental.cryptography.Concepts

// Define the source for cryptographic hash algorithm instances to be analyzed
from HashAlgorithm cryptoHashInstance

// Construct query results by selecting each identified hash algorithm instance
// and providing a descriptive message containing the algorithm's name
select cryptoHashInstance, 
       "Use of algorithm " + cryptoHashInstance.getName()