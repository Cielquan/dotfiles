/** @type {import("prettier").Config} */
const config = {
  printWidth: 100,
  endOfLine: "auto",
  trailingComma: "all",
  plugins: [],
  overrides: [
    // Revert JSONC parsing:
    // https://github.com/prettier/prettier/issues/15553
    {
      files: ["**/.markdownlint-cli2.jsonc"],
      options: {
        parser: "json",
      },
    },
  ],
};

export default config;
