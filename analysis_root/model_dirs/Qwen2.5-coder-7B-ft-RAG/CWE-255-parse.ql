/**
 * @name CWE-255: Weak Hashing of Sensitive Data
 * @description Detection of cryptographic hash functions used for processing sensitive data, where the algorithm strength falls below industry standards.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-255
 */

// Import Python library for analyzing code
import python

// Import specific module for detecting weak hashing of sensitive data
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery

// Define query predicate to identify instances of weak hashing of sensitive data
query predicate problems = WeakSensitiveDataHashingFlow::flowPath(origin, destination);