/**
 * @name Alert suppression analysis
 * @description Detects and evaluates alert suppression mechanisms in Python codebases,
 *              providing visibility into how warnings and alerts are being suppressed.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL utilities for alert suppression handling
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
// Import Python comment analysis utilities
private import semmle.python.Comment as PythonComment

// Represents AST nodes with precise location tracking capabilities
class LocationAwareAstNode instanceof PythonComment::AstNode {
  // Verify if node matches specified file location coordinates
  predicate hasLocationInfo(
    string fPath, int sLine, int sCol, int eLine, int eCol
  ) {
    super.getLocation().hasLocationInfo(fPath, sLine, sCol, eLine, eCol)
  }

  // Generate descriptive string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with detailed location tracking and content access
class DetailedSingleLineComment instanceof PythonComment::Comment {
  // Check if comment corresponds to given location coordinates
  predicate hasLocationInfo(
    string fPath, int sLine, int sCol, int eLine, int eCol
  ) {
    super.getLocation().hasLocationInfo(fPath, sLine, sCol, eLine, eCol)
  }

  // Extract textual content of the comment
  string getText() { result = super.getContents() }

  // Provide descriptive string representation of the comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using AlertSuppressionUtil template
import AlertSuppressionUtil::Make<LocationAwareAstNode, DetailedSingleLineComment>

/**
 * A suppression comment following the noqa convention. This is widely recognized
 * by Python linters including pylint and pyflakes, serving as a standard
 * mechanism for suppressing warnings in Python code.
 */
// Represents noqa-style suppression comments with pattern matching
class NoqaSuppressionComment extends SuppressionComment instanceof DetailedSingleLineComment {
  // Constructor identifying noqa comment patterns with case-insensitive matching
  NoqaSuppressionComment() {
    DetailedSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return standardized suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define coverage scope for this suppression annotation
  override predicate covers(
    string fPath, int sLine, int sCol, int eLine, int eCol
  ) {
    // Ensure comment location matches and enforce line-start positioning
    this.hasLocationInfo(fPath, sLine, _, eLine, eCol) and
    sCol = 1
  }
}