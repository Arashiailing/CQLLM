/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities with descriptive alias
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// Import Python comment processing utilities with descriptive alias
private import semmle.python.Comment as PythonComment

// Enhanced AST node wrapper with location capabilities
class AstNode instanceof PythonComment::AstNode {
  /** Check if node has specific location information */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location check to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Get string representation of the AST node */
  string toString() { result = super.toString() }
}

// Enhanced single-line comment wrapper with location and text access
class SingleLineComment instanceof PythonComment::Comment {
  /** Check if comment has specific location information */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location check to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Get the text content of the comment */
  string getText() { result = super.getContents() }

  /** Get string representation of the comment */
  string toString() { result = super.toString() }
}

// Establish alert suppression relationship using enhanced node types
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment recognized by Python linters (pylint, pyflakes).
 * This comment type is also respected by LGTM analysis.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /** Constructor matching noqa comment pattern (case-insensitive) */
  NoqaSuppressionComment() {
    // Match comment text against noqa pattern with optional suffix
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Get the annotation identifier for this suppression */
  override string getAnnotation() { result = "lgtm" }

  /** Determine the code range covered by this suppression */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Use comment's location information and enforce line-start position
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}