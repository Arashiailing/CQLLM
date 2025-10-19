import python

/**
 * @name CSRF protection weakened or disabled
 * @description Detects code that disables or weakens CSRF protection mechanisms
 */
predicate is_csrf_disabled(Function f) {
  // Check for explicit CSRF exemption decorators
  exists(Decorator d |
    d.getFunction() = f and
    d.getName() = "csrf_exempt" and
    d.getFile().getPackage() = "flask"
  ) or
  
  // Check for bypasses of CSRF protection logic
  exists(Call c |
    c.getExpression().getName() = "url_for" and
    c.getArguments()[0].getValue().getStringValue() = "static" and
    c.getFunction().getFile().getPackage() = "flask"
  ) or
  
  // Check for missing SameSite attribute in cookies
  exists(Assign a |
    a.getLeftHandSide().getName() = "response" and
    not exists(HttpResponseCookie h |
      h.getResponse() = a.getRightHandSide() and
      h.getAttribute("SameSite")!= null
    )
  )
}

from Function f
where is_csrf_disabled(f)
select f, "This function may disable or weaken CSRF protection mechanisms"