declare module "eslint-config-next/parser.js" {
  import type { Linter } from "eslint";

  const parser: Linter.Parser;
  export = parser;
}

declare module "eslint-plugin-chai-friendly" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      recommendedFlat: Linter.Config;
    };
  };
  export = plugin;
}

declare module "eslint-plugin-cypress/flat" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      recommended: Linter.Config;
    };
  };
  export = plugin;
}

declare module "eslint-plugin-jest" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      "flat/recommended": Linter.Config;
      "flat/style": Linter.Config;
    };
  };
  export = plugin;
}

declare module "eslint-plugin-jest-dom" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      "flat/recommended": Linter.Config;
    };
  };
  export = plugin;
}

declare module "eslint-plugin-mocha" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      all: Linter.Config;
      recommended: Linter.Config;
    };
  };
  export = plugin;
}

declare module "eslint-plugin-react" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      flat: {
        recommended: Linter.Config;
      };
    };
  };
  export = plugin;
}

declare module "eslint-plugin-testing-library" {
  import type { ESLint, Linter } from "eslint";

  const plugin: ESLint.Plugin & {
    configs: {
      "flat/react": Linter.Config;
    };
  };
  export = plugin;
}
