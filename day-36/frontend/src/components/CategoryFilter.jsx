const categories = [
  "All",
  "Basics",
  "Images",
  "Containers",
  "Debugging",
  "Configuration",
  "Volumes",
  "Networks",
  "Compose",
  "Build",
  "Registry",
  "Cleanup",
  "System",
];

function CategoryFilter({ selectedCategory, setSelectedCategory }) {
  return (
    <div className="category-container">
      {categories.map((category) => (
        <button
          key={category}
          className={`category-button ${
            selectedCategory === category ? "active" : ""
          }`}
          onClick={() => setSelectedCategory(category)}
        >
          {category}
        </button>
      ))}
    </div>
  );
}

export default CategoryFilter;
