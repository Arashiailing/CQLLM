/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @description The product writes sensitive information to a log file.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.4
 * @precision high
 * @id py/checks
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery