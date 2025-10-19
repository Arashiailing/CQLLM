/**
 * @name Insecure randomness vulnerability
 * @description Detects the use of cryptographically weak pseudo-random number generators
 *              for generating security-sensitive values, which could enable attackers
 *              to predict the generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python library import providing fundamental constructs for Python code analysis
import python

// Experimental security module import containing specialized logic for identifying
// insecure random number generation patterns in Python code
import experimental.semmle.python.security.InsecureRandomness

// Data flow analysis framework import enabling tracking of data propagation
// through the program for taint analysis
import semmle.python.dataflow.new.DataFlow

// Path graph module import facilitating visualization and representation of
// data flow paths between source and sink nodes
import InsecureRandomness::Flow::PathGraph

// Main query definition to identify insecure random value flows:
// - sourceNode: Represents the origin of insecure random value generation
// - sinkNode: Represents the security-sensitive context where the value is used
from InsecureRandomness::Flow::PathNode sourceNode, InsecureRandomness::Flow::PathNode sinkNode
where InsecureRandomness::Flow::flowPath(sourceNode, sinkNode) // Constraint: Verifies existence of data flow path
select sinkNode.getNode(), sourceNode, sinkNode, "Cryptographically insecure $@ in a security context.",
  sourceNode.getNode(), "random value" // Result format: sink node, source node, path, and alert message