/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @description Detects uses of MD5 and SHA1 hashing algorithms for sensitive data,
 *              which are considered weak and insecure.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision medium
 * @id py/pycrypto/md5-sha1-hash
 * @tags security
 *       experimental
 *       external/cwe/cwe-310
 */

// Import Python library for analyzing Python code
import python

// Import experimental module for detecting cryptographic weaknesses related to hashing
import semmle.python.security.dataflow.HashingAnalysis

// Define query predicate to identify vulnerable hashing operations
query predicate vulnerableHashingOperation = HashingAnalysis::weakHashFunction/3;

// Identify and report all occurrences of weak hashing operations
from HashingAnalysis::TaintedString taintedInput, HashingAnalysis::HashingOperation op, string algorithm
where
  // Verify that there is a flow path from the tainted input to the hashing operation
  HashingAnalysis::flowPath(taintedInput, op) and
  
  // Extract the name of the hashing algorithm being used
  algorithm = op.getHashFunction()
select op, "Hash function $@ is used for sensitive data.", algorithm