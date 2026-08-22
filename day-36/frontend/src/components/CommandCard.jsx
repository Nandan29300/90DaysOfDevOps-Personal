import { useState } from "react";

function CommandCard({ command }) {
  const [copied, setCopied] = useState(false);

  const copyCommand = async () => {
    try {
      // Preferred method for HTTPS / localhost
      if (
        navigator.clipboard &&
        window.isSecureContext
      ) {
        await navigator.clipboard.writeText(command.command);
      } else {
        // Fallback for HTTP EC2 environments
        const textArea = document.createElement("textarea");

        textArea.value = command.command;

        textArea.style.position = "fixed";
        textArea.style.left = "-9999px";
        textArea.style.top = "0";

        document.body.appendChild(textArea);

        textArea.focus();
        textArea.select();

        document.execCommand("copy");

        document.body.removeChild(textArea);
      }

      setCopied(true);

      setTimeout(() => {
        setCopied(false);
      }, 1800);
    } catch (error) {
      console.error("Copy failed:", error);

      alert("Copy failed. Please copy the command manually.");
    }
  };

  return (
    <article className="command-card">

      {/* Card header */}
      <div className="card-top">

        <span className="command-category">
          {command.category}
        </span>

        <span className="command-number">
          #{String(command.id).padStart(2, "0")}
        </span>

      </div>

      {/* Title */}
      <h3 className="command-title">
        {command.title}
      </h3>

      {/* Description */}
      <p className="command-description">
        {command.description}
      </p>

      {/* Command */}
      <div className="command-box">

        <code>
          {command.command}
        </code>

        <button
          className={`copy-button ${copied ? "copied" : ""}`}
          onClick={copyCommand}
          title="Copy command"
        >
          {copied ? "✓ Copied" : "📋 Copy"}
        </button>

      </div>

      {/* Example */}
      {command.example && (
        <div className="example">

          <span className="example-label">
            Example
          </span>

          <code>
            {command.example}
          </code>

        </div>
      )}

    </article>
  );
}

export default CommandCard;
