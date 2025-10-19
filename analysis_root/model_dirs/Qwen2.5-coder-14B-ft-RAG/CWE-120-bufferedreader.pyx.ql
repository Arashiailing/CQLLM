/**
 * @name CWE-120: Buffer Copy without Checking Size of Input ('Classic Buffer Overflow')
 * @description The product copies an input buffer to an output buffer without verifying that the size of the input buffer is less than the size of the output buffer.
 * @kind problem
 * @id py/classic-buf-over
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @tags correctness
 *       security
 *       external/cwe/cwe-120
 */

import python
import semmle.python.ApiGraphs

// Predicate to identify unsafe copy operations that lack proper size checking
predicate unsafeCopyOperation(API::CallNode operation) {
  // Check if the operation is either memcpy or memmove (both C standard functions for memory copying)
  operation = API::moduleImport("libc").getMember("string.h").getMember(("memcpy", "memmove")).getACall()
}

// Main query to find unsafe buffer copy operations
from API::CallNode operation
where
  // Verify that the identified operation is indeed unsafe based on our defined predicate
  unsafeCopyOperation(operation)
select operation,
  // Generate descriptive message indicating the nature of the unsafe operation
  "Unsafe buffer copy function call; source length unknown at this point."