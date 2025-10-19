/**
 * @name CWE-534: DEPRECATED: Information Exposure Through Debug Log Files
 * @description Storing sensitive information in clear text logs can expose this information
 *              to unauthorized access.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision low
 * @id py/CWE-534
 * @tags security
 *       external/cwe/cwe-534
 */

// Import Python library for analyzing code
import python

// Import custom module for identifying cleartext storage vulnerabilities
import CleartextStorageQuery

// Define query predicate to identify vulnerable cleartext storage instances
query predicate vulnerableClearTextStorage(CleartextStorageInstance instance) {
  // Condition: instance represents a cleartext storage operation
  CleartextStorage::instance()
}

// Generate results for each identified cleartext storage vulnerability
from CleartextStorageInstance instance
where vulnerableClearTextStorage(instance)
select instance.getNode(), "Writing $@ to a file without encryption.", instance.getFile(), "confidential data"