import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects improper authentication patterns in Python code.
 */
from Method m, Call c
where
  c.getMethod() = m and
  (   // Check for direct password comparison with hardcoded values
      c.getExpression().toString() like "password == \"%\"'" or
      c.getExpression().toString() like "pwd == \"[a-zA-Z0-9]{4,}\"" or
      c.getExpression().toString() like "if __user__ == \"admin\" and __pass__ == \"root\""
  ) or
  (   // Check for missing authentication checks in critical functions
      m.getName() = "login" and
      not exists(Invoke i | i.getCallee() = c and i.getMethod().getName() = "verify_credentials")
  ) or
  (   // Check for insecure session handling
      m.getName() = "handle_session" and
      c.getExpression().toString() like "session_id == \"[0-9A-Fa-f]{32}\""
  )
select c, "Potential CWE-287: Improper Authentication detected"