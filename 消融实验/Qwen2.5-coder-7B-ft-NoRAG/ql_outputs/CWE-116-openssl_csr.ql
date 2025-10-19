/**
 * @name Bad HTML filtering regexp
 * @description Matching HTML tags using regular expressions is hard to do right, and can easily lead to security issues.
 * @id py/openssl_csr
 */
import python
import semmle.python.security.dataflow.BadTagFilterQuery

from BadTagFilterQuery::Problem p
select p, "Potential security issue due to bad HTML filtering regexp."