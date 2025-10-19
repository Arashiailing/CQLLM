/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/hkdf
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.ApiGraphs

// Returns all nodes that represent calls to HKDFExpandLabel()
private API::Node get_hkdf_expand_label_calls() {
  result = API::moduleImport("hazmat.primitives.kdf.hkdf").getMember("HKDFExpandLabel")
         .getReturn()
         .getACall()
}

// Returns all nodes that represent calls to hkdf_expand_label()
private API::Node get_hkdf_expand_label_functions() {
  result = API::moduleImport("cryptography.hazmat.backends.openssl.backend").getMember(
            "hkdf_expand_label"
          )
         .getReturn()
         .getACall()
}

// Returns all nodes that represent calls to HKDF.expand_label()
private API::Node get_hkdf_expand_calls() {
  result = API::moduleImport("cryptography.hazmat.primitives.kdf.hkdf").getMember("HKDF")
         .getReturn()
         .getMember("expand_label")
         .getReturn()
         .getACall()
}

// Finds all relevant function calls related to HKDF operations
from API::CallNode call_node
where
  call_node = get_hkdf_expand_label_calls() or
  call_node = get_hkdf_expand_label_functions() or
  call_node = get_hkdf_expand_calls()
select call_node, "Using 'hkdf_expand_label' with user-controlled data may be unsafe."