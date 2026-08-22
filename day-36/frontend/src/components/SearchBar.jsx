function SearchBar({ search, setSearch }) {
  return (
    <div className="search-container">
      <span className="search-icon">⌕</span>

      <input
        type="text"
        placeholder="Search Docker commands..."
        value={search}
        onChange={(event) => setSearch(event.target.value)}
      />

      {search && (
        <button
          className="clear-button"
          onClick={() => setSearch("")}
        >
          ×
        </button>
      )}
    </div>
  );
}

export default SearchBar;
