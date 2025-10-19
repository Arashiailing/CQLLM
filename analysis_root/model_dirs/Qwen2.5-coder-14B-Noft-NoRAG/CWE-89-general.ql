import python

/**
 * Detects SQL injection vulnerabilities where user-controlled input is used to build SQL queries.
 */
from StringConcatenation concat, UserInput input
where concat.getAnArgument() = input
select concat, "SQL query built from user-controlled sources is vulnerable to SQL injection."