import { useEffect, useState } from "react";

import Header from "./components/Header";
import SearchBar from "./components/SearchBar";
import CategoryFilter from "./components/CategoryFilter";
import CommandCard from "./components/CommandCard";

import "./App.css";

function App() {
  const [commands, setCommands] = useState([]);
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Fetch Docker commands from backend API
  useEffect(() => {
    const fetchCommands = async () => {
      try {
        const response = await fetch("/api/commands");

        if (!response.ok) {
          throw new Error("Failed to fetch commands");
        }

        const data = await response.json();

        setCommands(data);
      } catch (err) {
        console.error("API error:", err);
        setError("Unable to load Docker commands.");
      } finally {
        setLoading(false);
      }
    };

    fetchCommands();
  }, []);

  // Filter commands based on search + category
  const filteredCommands = commands.filter((command) => {
    const searchText = search.toLowerCase();

    const matchesSearch =
      command.title?.toLowerCase().includes(searchText) ||
      command.command?.toLowerCase().includes(searchText) ||
      command.description?.toLowerCase().includes(searchText);

    const matchesCategory =
      selectedCategory === "All" ||
      command.category === selectedCategory;

    return matchesSearch && matchesCategory;
  });

  return (
    <div className="app">
      {/* Header */}
      <Header />

      <main className="container">
        {/* Hero section */}
        <section className="hero">
          <div className="hero-badge">
            🐳 Docker Reference
          </div>

          <h1>
            Learn Docker.
            <br />
            <span>One command at a time.</span>
          </h1>

          <p>
            Quickly find the Docker command you need,
            understand what it does, and copy it instantly.
          </p>
        </section>

        {/* Search */}
        <SearchBar
          search={search}
          setSearch={setSearch}
        />

        {/* Categories */}
        <CategoryFilter
          selectedCategory={selectedCategory}
          setSelectedCategory={setSelectedCategory}
        />

        {/* Results header */}
        <div className="results-header">
          <h2>Docker Commands</h2>

          <span>
            {filteredCommands.length} commands
          </span>
        </div>

        {/* Loading */}
        {loading && (
          <div className="message">
            Loading Docker commands...
          </div>
        )}

        {/* Error */}
        {!loading && error && (
          <div className="message error">
            {error}
          </div>
        )}

        {/* Empty result */}
        {!loading &&
          !error &&
          filteredCommands.length === 0 && (
            <div className="message">
              No Docker commands found.
            </div>
          )}

        {/* Command cards */}
        {!loading && !error && (
          <section className="command-grid">
            {filteredCommands.map((command) => (
              <CommandCard
                key={command.id}
                command={command}
              />
            ))}
          </section>
        )}
      </main>

      {/* Footer */}
      <footer>
        <p>
          🐳 DockerBuddy · Built for Docker learners
        </p>
      </footer>
    </div>
  );
}

export default App;
