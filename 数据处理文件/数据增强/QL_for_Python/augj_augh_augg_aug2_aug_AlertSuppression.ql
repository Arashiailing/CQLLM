/**
 * @name Alert suppression analysis
 * @description Identifies and analyzes alert suppression mechanisms in Python codebases,
 *              providing insights into how warnings and alerts are being suppressed.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL utilities for handling alert suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
// Import Python comment analysis utilities for detailed comment processing
private import semmle.python.Comment as PythonComment

// Enhanced AST node class with comprehensive location tracking capabilities
class EnhancedLocationNode instanceof PythonComment::AstNode {
  // Check if the node's location matches the specified file coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate a descriptive string representation of the AST node
  string toString() { result = super.toString() }
}

// Detailed representation of single-line comments with location tracking
class AnalyzedSingleLineComment instanceof PythonComment::Comment {
  // Verify if the comment's location corresponds to the given coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract the textual content of the comment
  string getText() { result = super.getContents() }

  // Provide a descriptive string representation of the comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using the AlertSuppressionUtil template
import AlertSuppressionUtil::Make<EnhancedLocationNode, AnalyzedSingleLineComment>

/**
 * A suppression comment following the noqa convention. This is widely recognized
 * by Python linters including pylint and pyflakes, serving as a standard
 * mechanism for suppressing warnings in Python code.
 */
// Represents noqa-style suppression comments with specific pattern matching
class StandardNoqaSuppression extends SuppressionComment instanceof AnalyzedSingleLineComment {
  // Constructor that identifies noqa comment patterns with case-insensitive matching
  StandardNoqaSuppression() {
    AnalyzedSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
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