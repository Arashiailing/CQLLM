import python

/**
 * Detects potential URL redirect vulnerabilities by checking for unsafe redirect handling patterns.
 */
predicate isUnsanitizedRedirect(String urlParam, String methodName)
    = (urlParam.starts_with("http") and not urlParam.contains("://example.com"))
       and (methodName = "redirect" or methodName = "sendRedirect")

from Method m
where 
    m.name = "redirect" or m.name = "sendRedirect"
    and exists (Call c < m; c.hasArgument(arg | arg.value = "urlParam"))
    and isUnsanitizedRedirect(arg.value, m.name)
select m, "Potential unsafe redirect detected - URL parameter not properly sanitized"