import python

/**
 * Query to detect CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * This query looks for instances where sensitive information is stored in cleartext.
 */

from VariableAccess varAccess, StringLiteral sensitiveData
where sensitiveData.getValue().matches("%password%|%secret%|%token%|%key%|%credential%")
  and varAccess.getExpr() = sensitiveData
select varAccess, "Sensitive information is stored in cleartext: " + sensitiveData.getValue()