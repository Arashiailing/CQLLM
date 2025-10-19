/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.
 *              Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/client-cwe-295
 * @tags security
 *       external/cwe/cwe-295
 */

import python
import CleartextLoggingQuery
select p, "Sensitive data is logged to stdout/stderr without encryption."