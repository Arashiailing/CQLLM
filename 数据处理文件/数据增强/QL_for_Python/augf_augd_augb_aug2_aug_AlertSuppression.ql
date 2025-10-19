/**
 * @name Alert suppression
 * @description Provides comprehensive details about alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for managing suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as PythonComment

// Import suppression relationship generator using AST nodes and comments
import AlertSuppUtil::Make<AstNode, SingleLineComment>

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof PythonComment::AstNode {
  // Generate string representation of the AST node
  string toString() { result = super.toString() }

  // Verify if the node's location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Generate string representation of the comment
  string toString() { result = super.toString() }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Verify if the comment's location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

/**
 * Represents a noqa suppression comment. Recognized by both pylint and pyflakes,
 * and therefore should be respected by lgtm.
 */
// Denotes suppression comments following the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor identifying noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provides the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Defines the code coverage range for this suppression annotation
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure the comment's location matches and starts at line beginning
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}