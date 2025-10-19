/**
 * @name Alert suppression analysis
 * @description Identifies and analyzes alert suppression mechanisms in Python codebases,
 *              providing insights into how warnings and alerts are being suppressed.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL utilities for alert suppression handling
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
// Import Python comment analysis utilities
private import semmle.python.Comment as PythonComment

// Represents AST nodes with enhanced location tracking capabilities
class LocationAwareAstNode instanceof PythonComment::AstNode {
  // Determine if the node matches specified file location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate a descriptive string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with detailed location tracking and content extraction
class DetailedSingleLineComment instanceof PythonComment::Comment {
  // Check if the comment corresponds to the given location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Provide a descriptive string representation of the comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using AlertSuppressionUtil template
import AlertSuppressionUtil::Make<LocationAwareAstNode, DetailedSingleLineComment>

/**
 * A suppression comment following the noqa convention. This is widely recognized
 * by Python linters including pylint and pyflakes, serving as a standard
 * mechanism for suppressing warnings in Python code.
 */
// Represents noqa-style suppression comments with specific pattern matching
class NoqaSuppressionComment extends SuppressionComment instanceof DetailedSingleLineComment {
  // Constructor that identifies noqa comment patterns with case-insensitive matching
  NoqaSuppressionComment() {
    DetailedSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the standardized suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the coverage scope for this suppression annotation
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure comment location matches and enforce line-start positioning
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}