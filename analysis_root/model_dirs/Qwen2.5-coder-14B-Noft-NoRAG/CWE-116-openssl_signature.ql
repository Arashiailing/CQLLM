import python

/**
 * CWE-116: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')
 */

class BadHTMLFiltering extends SecurityQuery {
  BadHTMLFiltering() {
    exists(RegExp r |
      r.getPattern() = /<[^>]*>/ and
      exists(Call c |
        c.getCallee().getName() = "re.match" and
        c.getArgument(0) = r
      )
    )
  }
}