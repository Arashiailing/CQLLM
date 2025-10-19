/**
 * @name Alert suppression
 * @description Identifies and processes alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL utilities for handling alert suppression mechanisms
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import Python comment processing utilities
private import semmle.python.Comment as CommentProcessor

// Define a base class representing Python syntax elements in the AST
class PySyntaxNode instanceof CommentProcessor::AstNode {
  /** Retrieve location information for the syntax node */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate to parent class for precise location data
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Provide string representation of the syntax node */
  string toString() { result = super.toString() }
}

// Define class representing single-line comments in Python code
class PySingleLineComment instanceof CommentProcessor::Comment {
  /** Retrieve location information for the comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate to parent class for precise location data
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Extract the text content of the comment */
  string getText() { result = super.getContents() }

  /** Provide string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply template to establish suppression relationships between AST nodes and comments
import SuppressionUtils::Make<PySyntaxNode, PySingleLineComment>

/**
 * Represents noqa-style suppression comments compatible with Pylint and Pyflakes
 * These comments are recognized by the LGTM analyzer for alert suppression
 */
class NoqaSuppression extends SuppressionComment instanceof PySingleLineComment {
  /** Constructor: validates if the comment follows noqa format */
  NoqaSuppression() {
    // Check if comment text matches noqa pattern (case-insensitive, allowing surrounding whitespace)
    PySingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Return the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Define the code range covered by this suppression comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure comment is at line beginning and location information matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}