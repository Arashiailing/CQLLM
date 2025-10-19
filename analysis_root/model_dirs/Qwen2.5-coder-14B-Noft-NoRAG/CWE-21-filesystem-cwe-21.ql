import python

/**
 * CWE-21: Pathname Traversal and Equivalence Errors
 */
from File file, Expr filePathExpr
where file.getFileSystemAccess().getFilePath() = filePathExpr
  and filePathExpr instanceof StringLiteral
  and filePathExpr.asString().contains("..")
select file, filePathExpr, "Potentially vulnerable to CWE-21: Pathname Traversal and Equivalence Errors"