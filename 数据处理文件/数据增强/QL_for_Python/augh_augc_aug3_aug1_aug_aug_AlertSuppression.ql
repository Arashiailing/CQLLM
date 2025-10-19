/**
 * @name Alert suppression mechanism
 * @description Detects and handles alert suppression annotations in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import necessary modules for alert suppression and comment handling
private import codeql.util.suppression.AlertSuppression as AlertSuppressionModule
private import semmle.python.Comment as CommentModule

// Define a class representing Python abstract syntax tree nodes
class PySyntaxTreeNode instanceof CommentModule::AstNode {
  /** Extract location details for the syntax node (file path and line/column boundaries) */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Utilize parent class method to obtain location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Generate string representation of the syntax node */
  string toString() { result = super.toString() }
}

// Define a class representing individual line comments in Python
class PySingleLineComment instanceof CommentModule::Comment {
  /** Extract location details for the comment (file path and line/column boundaries) */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Utilize parent class method to obtain location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Retrieve the actual text content of the comment */
  string getText() { result = super.getContents() }

  /** Generate string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply template to establish suppression relationships between syntax nodes and comments
import AlertSuppressionModule::Make<PySyntaxTreeNode, PySingleLineComment>

/**
 * Pylint and Pyflakes compatible noqa suppression annotations
 * These annotations should be recognized by the LGTM analysis engine
 */
class NoqaSuppressionComment extends SuppressionComment instanceof PySingleLineComment {
  /** Constructor: Verify if the comment follows the noqa specification */
  NoqaSuppressionComment() {
    // Validate comment text against noqa pattern (case-insensitive, with optional surrounding whitespace)
    PySingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Provide the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Specify the code scope affected by the suppression annotation */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Ensure the comment appears at line start and coordinates match
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}