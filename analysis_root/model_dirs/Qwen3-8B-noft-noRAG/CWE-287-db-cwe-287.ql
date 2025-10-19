import python

/**
 * Detects improper authentication by checking for:
 * - Direct string comparisons of user input with hardcoded values
 * - Missing secure credential storage practices
 * - Insecure session management patterns
 */
from Method m, Call c, StringLiteral sl
where 
  (c.getTarget() = m and m.getName() = "check_password" or 
   m.getName() = "authenticate_user" or 
   m.getName() = "login") and
  c.getArgument(0).getType().getName() = "str" and
  c.getArgument(1).getType().getName() = "str" and
  sl.getValue().matches("^[a-zA-Z0-9]{8,}$") and
  (sl.getLocation().getFile() = c.getLocation().getFile() or 
   sl.getLocation().getFile() = c.getLocation().getFile())
select sl, "Potential CWE-287: Improper Authentication detected - insecure credential handling", 
       c, "Insecure password comparison method"