import semmle.python.Python

from StringLiteral s
where s.getValue() matches /password|secret|key|token|api|auth|bearer/i
select s, "Potential CWE-522: Cleartext storage of credentials detected in string literal."