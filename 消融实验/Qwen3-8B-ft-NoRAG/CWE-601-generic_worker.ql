import python

/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input may cause redirection to malicious web sites.
 * @id py/generic_worker
 */
from Call c, Input i
where c.getTarget().getName() = "http.redirect" and
      c.getArgument(0).getValue() = i
select c, i, "Potential URL redirection based on unvalidated user input"