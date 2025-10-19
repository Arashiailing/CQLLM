/**
 * @name Memory cache poisoning via unsafe deserialization
 * @description Deserializing user-supplied data into memory-based caching mechanisms may allow
 *              an attacker to execute arbitrary code through crafted inputs.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/memcached
 * @tags external/cwe/cwe-502
 *       security
 *       serialization
 */

// Import Python library for code analysis
import python

// Import module specifically designed for detecting unsafe deserialization vulnerabilities
import semmle.python.security.dataflow.UnsafeDeserializationQuery

// Define classes representing nodes in the flow graph for data tracking
import UnsafeDeserializationFlow::PathGraph

// Identify pairs of source and sink nodes where data flows between them
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink

// Ensure there exists a complete data flow path from source to sink
where UnsafeDeserializationFlow::flowPath(source, sink)

// Generate results indicating vulnerable sinks along with source details
select sink.getNode(), source, sink, "Memory cache is deserialized with $@", source.getNode(), "untrusted user data"