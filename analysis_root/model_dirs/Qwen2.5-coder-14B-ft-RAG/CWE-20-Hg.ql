/**
* @name CWE-20: Improper Input Validation
* @description The product receives input or data, but it does
*              not validate or incorrectly validates that the input has the
*              properties that are required to process the data safely and
*              correctly.
* @kind problem
* @problem.severity error
* @security-severity 7.8
* @precision high
* @id py/incomplete-hostname-regexp
* @tags correctness
*       security
*       external/cwe/cwe-020
*/

import semmle.python.security.regexp.HostnameRegex

from RegExp re, int n1, int n2, string msg
where
  (
    re.isIgnoreCase()
    and
    (
      n1 = 0 and n2 = 0 and
      msg = "contains an unescaped dot"
      or
      n1 = 0 and n2 = 1 and
      msg = "starts with a wildcard"
      or
      n1 = 0 and n2 = 2 and
      msg = "starts with a wildcard followed by a dot"
      or
      n1 = 1 and n2 = 0 and
      msg = "ends with a wildcard"
      or
      n1 = 1 and n2 = 2 and
      msg = "ends with a dot followed by a wildcard"
      or
      n1 = 2 and n2 = 0 and
      msg = "contains wildcards at both ends"
      or
      n1 = 2 and n2 = 1 and
      msg = "contains wildcards at both ends with a dot before the final one"
      or
      n1 = 2 and n2 = 2 and
      msg = "contains wildcards at both ends with dots between them"
    )
  )
  or
  (
    not re.isIgnoreCase()
    and
    (
      n1 = 0 and n2 = 0 and
      msg = "does not use case-insensitive matching"
      or
      n1 = 1 and n2 = 0 and
      msg = "is case-sensitive and starts with a wildcard"
      or
      n1 = 1 and n2 = 1 and
      msg = "is case-sensitive and starts with a wildcard followed by a dot"
      or
      n1 = 2 and n2 = 0 and
      msg = "is case-sensitive and ends with a wildcard"
      or
      n1 = 2 and n2 = 1 and
      msg = "is case-sensitive and ends with a dot followed by a wildcard"
      or
      n1 = 3 and n2 = 0 and
      msg = "is case-sensitive and contains wildcards at both ends"
      or
      n1 = 3 and n2 = 1 and
      msg = "is case-sensitive and contains wildcards at both ends with a dot before the final one"
      or
      n1 = 3 and n2 = 2 and
      msg = "is case-sensitive and contains wildcards at both ends with dots between them"
    )
  )
select re, "This hostname pattern " + msg + "."