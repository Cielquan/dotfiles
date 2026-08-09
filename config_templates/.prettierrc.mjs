/** @type {import("prettier").Config} */
const config = {
  printWidth: 100,
  endOfLine: "auto",
  trailingComma: "all",
  plugins: [],

  // NOTE: Plugin: prettier-plugin-tailwindcss
  tailwindConfig: "./tailwind.config.ts",
  tailwindFunctions: ["clsx", "twMerge", "cn", "cva"],
  tailwindAttributes: ["class", "className", "classNames"],

  // NOTE: Plugin: @trivago/prettier-plugin-sort-imports
  importOrder: ["<THIRD_PARTY_MODULES>", "^[@a-zA-Z]", "^[./]"],
  importOrderSeparation: true,
  importOrderSortSpecifiers: true,
  importOrderGroupNamespaceSpecifiers: true,

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
