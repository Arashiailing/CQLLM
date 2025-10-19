import python

/**
 * Detect potential CWE-119 vulnerabilities by identifying unsafe string manipulation patterns.
 */
predicate isPotentiallyUntrustedInput(String s)
    -- Simplified check for untrusted input sources (e.g., user input)
    (s.isGlobal() and s.getName() startsWith 'user_') or
    (s.isFunctionArg() and s.getType().getName() = "str") or
    (s.isLocalVariable() and s.getType().getName() = "str")

from String s, String sliceStart, String sliceEnd, String indexVar
where
    -- Check for unsafe string slicing with untrusted inputs
    (s.asExpr() instanceof StringLiteral) and
    (sliceStart.asExpr() instanceof Variable) and
    (sliceEnd.asExpr() instanceof Variable) and
    isPotentiallyUntrustedInput(sliceStart) and
    isPotentiallyUntrustedInput(sliceEnd)

select s, "Potential CWE-119: Unsafe string slicing with untrusted inputs"

from String s, Integer i
where
    -- Check for unsafe indexing with untrusted integers
    (s.asExpr() instanceof StringLiteral) and
    (i.asExpr() instanceof Variable) and
    isPotentiallyUntrustedInput(i)

select i, "Potential CWE-119: Unsafe string indexing with untrusted integer"