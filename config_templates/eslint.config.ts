// @ts-check
/* eslint-disable import-x/no-named-as-default-member */

// Based on `eslint-config-airbnb` and `eslint-config-next`

import path from "path";
import { fileURLToPath } from "url";

import { fixupConfigRules, includeIgnoreFile } from "@eslint/compat";
import { FlatCompat } from "@eslint/eslintrc";
import eslintJS from "@eslint/js";
import stylisticPlugin from "@stylistic/eslint-plugin";
import ConfusingGlobals from "confusing-browser-globals";
import nextJSParser from "eslint-config-next/parser.js";
import chaiFriendlyPlugin from "eslint-plugin-chai-friendly";
import cypressPlugin from "eslint-plugin-cypress/flat";
import importXPlugin from "eslint-plugin-import-x";
import jestPlugin from "eslint-plugin-jest";
import jestDomPlugin from "eslint-plugin-jest-dom";
import jsxA11yPlugin from "eslint-plugin-jsx-a11y";
import mochaPlugin from "eslint-plugin-mocha";
import nodePlugin from "eslint-plugin-n";
import prettierPluginRecommended from "eslint-plugin-prettier/recommended";
import reactPlugin from "eslint-plugin-react";
import reactCompiler from "eslint-plugin-react-compiler";
import reactHooks from "eslint-plugin-react-hooks";
import testingLibraryPlugin from "eslint-plugin-testing-library";
import globals from "globals";
import {
  config as tsEslintConfig,
  configs as tsEslintConfigs,
  plugin as tsEslintPlugin,
} from "typescript-eslint";

type RUN_ESLINT_RULESETS__ENV_VAR_VALUE =
  (typeof RUN_ESLINT_RULESETS__ENV_VAR_VALUE)[keyof typeof RUN_ESLINT_RULESETS__ENV_VAR_VALUE];
/** Rulesets to run when invoking eslint.
 *  Rulesets are set as comma separated list via the `RUN_ESLINT_RULESETS` envvar.
 *  The ruleset names can be set case-insensitive.
 *
 *  - ALL: run all rules configured
 *  - NORMAL: run all but expensive rules (default)
 *  - EXPENSIVE_ALL: run all expensive but not normal rules; import and type-checked
 *  - EXPENSIVE_IMPORT: run expensive import rules only
 *  - EXPENSIVE_TYPECHECKED: run expensive type-checked rules only
 *  - EXPENSIVE_REACT_COMPILER: run expensive react compiler rules only
 */
const RUN_ESLINT_RULESETS__ENV_VAR_VALUE = {
  ALL: "ALL",
  NORMAL: "NORMAL",
  EXPENSIVE_ALL: "EXPENSIVE_ALL",
  EXPENSIVE_IMPORT: "EXPENSIVE_IMPORT",
  EXPENSIVE_TYPECHECKED: "EXPENSIVE_TYPECHECKED",
  EXPENSIVE_REACT_COMPILER: "EXPENSIVE_REACT_COMPILER",
} as const;

type RULESET = (typeof RULESET)[keyof typeof RULESET];
const RULESET = {
  NORMAL: "NORMAL",
  EXPENSIVE_IMPORT: "EXPENSIVE_IMPORT",
  EXPENSIVE_TYPECHECKED: "EXPENSIVE_TYPECHECKED",
  EXPENSIVE_REACT_COMPILER: "EXPENSIVE_REACT_COMPILER",
} as const;

const RULESETS_TO_RUN = new Set<RULESET>();
(process.env.RUN_ESLINT_RULESETS?.split(",") ?? ["NORMAL"]).forEach((envvarRuleset) => {
  const ruleset = envvarRuleset.toUpperCase() as RUN_ESLINT_RULESETS__ENV_VAR_VALUE;
  switch (ruleset) {
    case "ALL": {
      RULESETS_TO_RUN.add(RULESET.NORMAL);
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_IMPORT);
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_TYPECHECKED);
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_REACT_COMPILER);
      break;
    }
    case "NORMAL": {
      RULESETS_TO_RUN.add(RULESET.NORMAL);
      break;
    }
    case "EXPENSIVE_ALL": {
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_IMPORT);
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_TYPECHECKED);
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_REACT_COMPILER);
      break;
    }
    case "EXPENSIVE_IMPORT": {
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_IMPORT);
      break;
    }
    case "EXPENSIVE_TYPECHECKED": {
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_TYPECHECKED);
      break;
    }
    case "EXPENSIVE_REACT_COMPILER": {
      RULESETS_TO_RUN.add(RULESET.EXPENSIVE_REACT_COMPILER);
      break;
    }
    default: {
      ((_ruleset: never) => {
        throw new Error(`Unknown ruleset: ${_ruleset as string}`);
      })(ruleset);
    }
  }
});

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const flatCompat = new FlatCompat();

type EslintConfig = EslintConfigArray[number];
type EslintConfigArray = ReturnType<typeof tsEslintConfig>;
type EslintPlugin = NonNullable<EslintConfig["plugins"]>[string];

const eslintConfig = [
  {
    name: "custom/global/ignores",
    ignores: [
      ...(includeIgnoreFile(path.resolve(__dirname, ".gitignore")).ignores ?? []),
      "**/*.bak/",
      "**/*.bak",
      "**/*.bak.*",
    ],
  },

  {
    name: "custom/global/files",
    files: ["**/*.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
  },

  {
    name: "custom/global/setup",
    linterOptions: {
      noInlineConfig: false,
      reportUnusedDisableDirectives: "off",
    },
    languageOptions: {
      globals: {
        ...globals.es2021,
        ...globals.serviceworker,
        ...globals.browser,
        ...globals.node,
      },
      parser: nextJSParser,
      parserOptions: {
        requireConfigFile: false,
        sourceType: "module",
        allowImportExportEverywhere: true,
        babelOptions: {
          presets: ["next/babel"],
          caller: {
            // Eslint supports top level await when a parser for it is included. We enable the parser by default for Babel.
            supportsTopLevelAwait: true,
          },
        },
        warnOnUnsupportedTypeScriptVersion: true,
      },
    },
    settings: {
      "import-x/parsers": {
        "@typescript-eslint/parser": [".ts", ".mts", ".cts", ".tsx", ".d.ts"],
      },
      "import-x/resolver": {
        "eslint-import-resolver-node": {
          extensions: [".js", ".jsx", ".ts", ".tsx"],
        },
        "eslint-import-resolver-typescript": {
          alwaysTryTypes: true,
        },
      },
    },
  },

  {
    ...eslintJS.configs.recommended,
    name: "plugin/eslint/recommended",
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/eslint",
        rules: {
          ...eslintJS.configs.recommended.rules,
          "array-callback-return": ["error", { allowImplicit: true }],
          "arrow-body-style": ["error", "as-needed", { requireReturnForObjectLiteral: true }],
          "block-scoped-var": "error",
          camelcase: ["error", { properties: "never", ignoreDestructuring: false }],
          "class-methods-use-this": "off",
          "consistent-return": "error",
          "constructor-super": "error",
          "default-case": ["error", { commentPattern: "^no default$" }],
          "default-case-last": "error",
          "default-param-last": "error",
          "dot-notation": ["error", { allowKeywords: true }],
          eqeqeq: ["error", "always", { null: "ignore" }],
          "for-direction": "error",
          "func-name-matching": [
            "off",
            "always",
            {
              includeCommonJSModuleExports: false,
              considerPropertyDescriptor: true,
            },
          ],
          "func-names": "warn",
          "func-style": ["error", "expression"],
          "getter-return": ["error", { allowImplicit: true }],
          "global-require": "off",
          "grouped-accessor-pairs": "error",
          "guard-for-in": "error",
          "logical-assignment-operators": [
            "off",
            "always",
            {
              enforceForIfStatements: true,
            },
          ],
          "max-len": [
            "off",
            100,
            { ignorePattern: "([^\\n\\r]{95,100}\\{(?:'|\") (?:'|\")\\})|^import|^export" },
          ],
          "new-cap": [
            "error",
            {
              newIsCap: true,
              newIsCapExceptions: [],
              capIsNew: false,
              capIsNewExceptions: ["Immutable.Map", "Immutable.Set", "Immutable.List"],
            },
          ],
          "no-alert": "warn",
          "no-array-constructor": "error",
          "no-async-promise-executor": "error",
          "no-await-in-loop": "error",
          "no-bitwise": "warn",
          "no-caller": "error",
          "no-case-declarations": "error",
          "no-class-assign": "error",
          "no-compare-neg-zero": "error",
          "no-cond-assign": ["error", "always"],
          "no-console": ["warn", { allow: ["warn", "error"] }],
          "no-const-assign": "error",
          "no-constant-binary-expression": "error",
          "no-constant-condition": "error",
          "no-constructor-return": "error",
          "no-control-regex": "error",
          "no-debugger": "error",
          "no-delete-var": "error",
          "no-dupe-args": "error",
          "no-dupe-class-members": "error",
          "no-dupe-else-if": "error",
          "no-dupe-keys": "error",
          "no-duplicate-case": "error",
          "no-else-return": ["error", { allowElseIf: false }],
          "no-empty": "error",
          "no-empty-character-class": "error",
          "no-empty-function": [
            "error",
            {
              allow: ["arrowFunctions", "functions", "methods"],
            },
          ],
          "no-empty-pattern": "error",
          "no-empty-static-block": "error",
          "no-eq-null": "error",
          "no-eval": "error",
          "no-ex-assign": "error",
          "no-extend-native": "error",
          "no-extra-bind": "error",
          "no-extra-boolean-cast": "error",
          "no-extra-label": "error",
          "no-fallthrough": "error",
          "no-func-assign": "error",
          "no-global-assign": ["error", { exceptions: [] }],
          "no-import-assign": "error",
          "no-implicit-coercion": [
            "error",
            {
              boolean: false,
              number: true,
              string: true,
              allow: [],
            },
          ],
          "no-implied-eval": "error",
          "no-inner-declarations": "error",
          "no-invalid-regexp": "error",
          "no-irregular-whitespace": "error",
          "no-iterator": "error",
          "no-label-var": "error",
          "no-labels": ["error", { allowLoop: false, allowSwitch: false }],
          "no-lone-blocks": "error",
          "no-lonely-if": "error",
          "no-loop-func": "error",
          "no-loss-of-precision": "error",
          "no-misleading-character-class": "error",
          "no-multi-assign": ["error"],
          "no-multi-str": "error",
          "no-nested-ternary": "error",
          "no-new": "error",
          "no-new-func": "error",
          "no-new-native-nonconstructor": "error",
          "no-new-wrappers": "error",
          "no-nonoctal-decimal-escape": "error",
          "no-obj-calls": "error",
          "no-object-constructor": "error",
          "no-octal": "error",
          "no-octal-escape": "error",
          "no-param-reassign": [
            "error",
            {
              props: true,
              ignorePropertyModificationsFor: [
                "acc", // for reduce accumulators
                "accumulator", // for reduce accumulators
                "e", // for e.returnvalue
                "ctx", // for Koa routing
                "context", // for Koa routing
                "req", // for Express requests
                "request", // for Express requests
                "res", // for Express responses
                "response", // for Express responses
                "$scope", // for Angular 1 scopes
                "staticContext", // for ReactRouter context
              ],
            },
          ],
          "no-plusplus": "error",
          "no-promise-executor-return": "error",
          "no-proto": "error",
          "no-prototype-builtins": "error",
          "no-redeclare": "error",
          "no-regex-spaces": "error",
          "no-restricted-exports": [
            "error",
            {
              restrictedNamedExports: [
                "default", // use `export default` to provide a default export
                "then", // this will cause tons of confusion when your module is dynamically `import()`ed, and will break in most node ESM versions
              ],
            },
          ],
          "no-restricted-globals": [
            "error",
            {
              name: "isFinite",
              message:
                "Use Number.isFinite instead https://github.com/airbnb/javascript#standard-library--isfinite",
            },
            {
              name: "isNaN",
              message:
                "Use Number.isNaN instead https://github.com/airbnb/javascript#standard-library--isnan",
            },
            ...ConfusingGlobals.map((g) => {
              return {
                name: g,
                message: `Use window.${g} instead. https://github.com/facebook/create-react-app/blob/HEAD/packages/confusing-browser-globals/README.md`,
              };
            }),
          ],
          "no-restricted-imports": [
            "error",
            {
              paths: [],
              patterns: [
                {
                  group: ["lucide-react"],
                  importNamePattern:
                    ".*(?<!Icon|^default|^icons|^createLucideIcon|^LucideIcon|^LucideProps)$",
                  message: "Icon import without Icon in name. Use e.g. 'CircleIcon' over 'Circle'.",
                },
              ],
            },
          ],
          "no-restricted-properties": [
            "error",
            {
              object: "arguments",
              property: "callee",
              message: "arguments.callee is deprecated",
            },
            {
              object: "global",
              property: "isFinite",
              message: "Please use Number.isFinite instead",
            },
            {
              object: "self",
              property: "isFinite",
              message: "Please use Number.isFinite instead",
            },
            {
              object: "window",
              property: "isFinite",
              message: "Please use Number.isFinite instead",
            },
            {
              object: "global",
              property: "isNaN",
              message: "Please use Number.isNaN instead",
            },
            {
              object: "self",
              property: "isNaN",
              message: "Please use Number.isNaN instead",
            },
            {
              object: "window",
              property: "isNaN",
              message: "Please use Number.isNaN instead",
            },
            {
              property: "__defineGetter__",
              message: "Please use Object.defineProperty instead.",
            },
            {
              property: "__defineSetter__",
              message: "Please use Object.defineProperty instead.",
            },
            {
              object: "Math",
              property: "pow",
              message: "Use the exponentiation operator (**) instead.",
            },
          ],
          "no-restricted-syntax": [
            "error",
            {
              selector: "ForInStatement",
              message:
                "for..in loops iterate over the entire prototype chain, which is virtually never what you want. Use Object.{keys,values,entries}, and iterate over the resulting array.",
            },
            {
              selector: "ForOfStatement",
              message:
                "iterators/generators require regenerator-runtime, which is too heavyweight for this guide to allow them. Separately, loops should be avoided in favor of array iterations like e.g. `[].every(...)`.",
            },
            {
              selector: "LabeledStatement",
              message:
                "Labels are a form of GOTO; using them makes code confusing and hard to maintain and understand.",
            },
            {
              selector: "WithStatement",
              message:
                "`with` is disallowed in strict mode because it makes code impossible to predict and optimize.",
            },
            // NOTE: TypeScript exclusive syntax
            {
              selector: "TSEnumDeclaration",
              message: "Don't use enums. Use objects instead or union types for local useage only.",
            },
            // NOTE: nextJS
            {
              selector:
                'CallExpression[callee.object.name="router"][callee.property.name="refresh"]',
              message:
                "`router.refresh()` only reloads server stuff, which is propably not what you want. If you want a page reload use `window.location.reload()` instead. Or ignore this error, when you really need `router.refresh()`. See https://github.com/vercel/next.js/discussions/62146",
            },
          ],
          "no-return-assign": ["error", "always"],
          "no-script-url": "error",
          "no-self-assign": ["error", { props: true }],
          "no-self-compare": "error",
          "no-sequences": "error",
          "no-setter-return": "error",
          "no-shadow": "error",
          "no-shadow-restricted-names": "error",
          "no-sparse-arrays": "error",
          "no-template-curly-in-string": "error",
          "no-this-before-super": "error",
          "no-throw-literal": "error",
          "no-undef": "error",
          "no-undef-init": "error",
          "no-unneeded-ternary": ["error", { defaultAssignment: false }],
          "no-unreachable": "error",
          "no-unreachable-loop": ["error", { ignore: [] }],
          "no-unsafe-finally": "error",
          "no-unsafe-negation": "error",
          "no-unsafe-optional-chaining": ["error", { disallowArithmeticOperators: true }],
          "no-unused-labels": "error",
          "no-unused-private-class-members": "error",
          "no-unused-vars": [
            "warn",
            {
              vars: "all",
              varsIgnorePattern: "^_",
              args: "after-used",
              argsIgnorePattern: "^_",
              ignoreRestSiblings: true,
              destructuredArrayIgnorePattern: "^_",
            },
          ],
          "no-use-before-define": [
            "error",
            { functions: true, classes: true, variables: true, allowNamedExports: true },
          ],
          "no-useless-catch": "error",
          "no-useless-concat": "error",
          "no-useless-backreference": "error",
          "no-useless-computed-key": "error",
          "no-useless-constructor": "error",
          "no-useless-escape": "error",
          "no-useless-rename": [
            "error",
            {
              ignoreDestructuring: false,
              ignoreImport: false,
              ignoreExport: false,
            },
          ],
          "no-useless-return": "error",
          "no-var": "error",
          "no-void": ["error", { allowAsStatement: true }],
          "no-with": "error",
          "object-shorthand": [
            "error",
            "always",
            {
              ignoreConstructors: false,
              avoidQuotes: true,
            },
          ],
          "one-var": ["error", "never"],
          "operator-assignment": ["error", "always"],
          "prefer-arrow-callback": [
            "error",
            {
              allowNamedFunctions: true,
              allowUnboundThis: true,
            },
          ],
          "prefer-const": [
            "error",
            {
              destructuring: "any",
              ignoreReadBeforeAssign: true,
            },
          ],
          "prefer-destructuring": [
            "error",
            {
              VariableDeclarator: { array: false, object: true },
              AssignmentExpression: { array: true, object: false },
            },
            { enforceForRenamedProperties: false },
          ],
          "prefer-exponentiation-operator": "error",
          "prefer-numeric-literals": "error",
          "prefer-promise-reject-errors": ["error", { allowEmptyReject: true }],
          "prefer-object-has-own": "error",
          "prefer-object-spread": "error",
          "prefer-regex-literals": ["error", { disallowRedundantWrapping: true }],
          "prefer-rest-params": "error",
          "prefer-spread": "error",
          "prefer-template": "error",
          "require-yield": "error",
          radix: ["error", "always"],
          "require-atomic-updates": "off", // NOTE: not enabled because it is very buggy
          strict: ["error", "never"],
          "symbol-description": "error",
          "unicode-bom": ["error", "never"],
          "use-isnan": "error",
          "valid-typeof": ["error", { requireStringLiterals: true }],
          "vars-on-top": "error",
          yoda: "error",
        },
      }
    : { name: "custom/eslint [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/eslint/for-react",
        files: ["**/*.{jsx,tsx}"],
        rules: {
          "class-methods-use-this": [
            "error",
            {
              exceptMethods: [
                "render",
                "getInitialState",
                "getDefaultProps",
                "getChildContext",
                "componentWillMount",
                "UNSAFE_componentWillMount",
                "componentDidMount",
                "componentWillReceiveProps",
                "UNSAFE_componentWillReceiveProps",
                "shouldComponentUpdate",
                "componentWillUpdate",
                "UNSAFE_componentWillUpdate",
                "componentDidUpdate",
                "componentWillUnmount",
                "componentDidCatch",
                "getSnapshotBeforeUpdate",
              ],
            },
          ],
        },
      }
    : { name: "custom/eslint-for-react [inactive]" },

  {
    ...prettierPluginRecommended,
    name: "plugin/prettier/recommended",
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/prettier",
        rules: {
          ...(prettierPluginRecommended.rules ?? {}),
          "prettier/prettier": "error",
        },
      }
    : { name: "custom/prettier [inactive]" },

  // TODO:#i# wait for v9 support
  // https://github.com/vercel/next.js/issues/64114
  // https://github.com/vercel/next.js/issues/64409
  ...fixupConfigRules(flatCompat.extends("plugin:@next/next/core-web-vitals")).map(
    (config, idx) => {
      let name: string;
      switch (idx) {
        case 0: {
          name = "recommended";
          break;
        }
        case 1: {
          name = "core-web-vitals";
          break;
        }
        default: {
          name = idx.toString();
          break;
        }
      }

      return {
        ...config,
        name: `plugin/next/${name}`,
        rules: {},
      };
    },
  ),

  // TODO:#i# wait for v9 support
  // https://github.com/vercel/next.js/issues/64114
  // https://github.com/vercel/next.js/issues/64409
  ...fixupConfigRules(flatCompat.extends("plugin:@next/next/core-web-vitals")).map(
    (config, idx) => {
      let name: string;
      switch (idx) {
        case 0: {
          name = "recommended";
          break;
        }
        case 1: {
          name = "core-web-vitals";
          break;
        }
        default: {
          name = idx.toString();
          break;
        }
      }

      return RULESETS_TO_RUN.has(RULESET.NORMAL)
        ? {
            name: `custom/next/${name}`,
            rules: {
              ...(config.rules ?? {}),
            },
          }
        : { name: `custom/next/${name} [inactive]` };
    },
  ),

  {
    ...importXPlugin.flatConfigs.recommended,
    name: "plugin/import-x/recommended",
    rules: {},
  },

  {
    ...importXPlugin.flatConfigs.react,
    name: "plugin/import-x/react",
    rules: {},
  },

  {
    ...importXPlugin.flatConfigs.typescript,
    name: "plugin/import-x/typescript",
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/import-x/normal",
        rules: {
          ...(importXPlugin.flatConfigs.recommended.rules ?? {}),
          ...importXPlugin.flatConfigs.typescript.rules,
          "import-x/consistent-type-specifier-style": ["error", "prefer-top-level"],
          "import-x/export": "error",
          "import-x/first": "error",
          "import-x/namespace": ["error", { allowComputed: true }],
          "import-x/newline-after-import": ["error", { count: 1, considerComments: true }],
          "import-x/no-absolute-path": "error",
          "import-x/no-amd": "error",
          "import-x/no-anonymous-default-export": "warn",
          "import-x/no-duplicates": "error",
          "import-x/no-dynamic-require": "error",
          "import-x/no-empty-named-blocks": "error",
          "import-x/no-extraneous-dependencies": [
            "error",
            {
              devDependencies: [
                "**/__tests__/**", // jest pattern
                "**/__mocks__/**", // jest pattern
                "**/*{.,_}{test,spec,cy}.{ts,tsx}", // tests where the extension or filename suffix denotes that it is a test
                "**/jest.config.{js,cjs,mjs}", // jest config
                "**/jest.setup.{js,cjs,mjs}", // jest setup
                "**/eslint.config.{js,cjs,mjs,ts}", // eslint config
                "testing-frontend/**",
                "translations/**",
                "scripts/**",
              ],
              optionalDependencies: false,
            },
          ],
          "import-x/no-import-module-exports": ["error", { exceptions: [] }],
          "import-x/no-mutable-exports": "error",
          "import-x/no-named-default": "error",
          "import-x/no-namespace": ["warn", { ignore: ["@radix-ui/*", "recharts", "*.png"] }],
          "import-x/no-nodejs-modules": "error",
          "import-x/no-self-import": "error",
          "import-x/no-useless-path-segments": ["error", { commonjs: true }],
          "import-x/no-webpack-loader-syntax": "error",
          "import-x/order": [
            "error",
            {
              "newlines-between": "always",
              alphabetize: { order: "asc", orderImportKind: "asc", caseInsensitive: false },
              groups: ["builtin", "external", ["parent", "sibling", "index", "internal"]],
              distinctGroup: true,
            },
          ],
        },
      }
    : { name: "custom/import-x/normal [inactive]" },

  RULESETS_TO_RUN.has(RULESET.EXPENSIVE_IMPORT)
    ? {
        name: "custom/import-x/expensive",
        rules: {
          "import-x/extensions": ["error", "ignorePackages", { ts: "never", tsx: "never" }],
          // NOTE: The `no-cycle` rule uses a lot of RAM and CI runs may run out of it, therefore reduction of depth.
          "import-x/no-cycle": ["error", { maxDepth: process.env.CI === "true" ? 5 : "∞" }],
          "import-x/no-named-as-default": "error",
          "import-x/no-unused-modules": [
            "off", // TODO:#i# enable once it supports CJS
            {
              ignoreExports: [],
              missingExports: true,
              unusedExports: true,
            },
          ],
        },
      }
    : { name: "custom/import-x/expensive [inactive]" },

  {
    ...nodePlugin.configs["flat/recommended-module"],
    name: "plugin/node/recommended-module",
    plugins: {
      n: nodePlugin,
    },
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/node",
        rules: {
          ...(nodePlugin.configs["flat/recommended-module"].rules ?? {}),
          "n/exports-style": ["error", "module.exports", { allowBatchAssign: false }],
          "n/hashbang": ["warn", { ignoreUnpublished: true }],
          "n/no-extraneous-import": ["error", { allowModules: ["user_roles"] }],
          "n/no-missing-import": "off",
          "n/no-missing-require": "off",
          "n/no-new-require": "error",
          "n/no-path-concat": "error",
          "n/no-sync": "warn",
          "n/no-unsupported-features/node-builtins": [
            "warn",
            {
              allowExperimental: true,
              ignores: ["navigator", "sessionStorage"],
            },
          ],
        },
      }
    : { name: "custom/node [inactive]" },

  {
    name: "plugin/stylistic",
    plugins: {
      "@stylistic": stylisticPlugin as EslintPlugin,
    },
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/stylistic",
        rules: {
          "@stylistic/lines-between-class-members": [
            "error",
            "always",
            { exceptAfterSingleLine: false },
          ],
          "@stylistic/spaced-comment": [
            "error",
            "always",
            {
              line: {
                exceptions: ["-", "+"],
                markers: ["=", "!", "/"], // space here to support sprockets directives, slash for TS /// comments
              },
              block: {
                exceptions: ["-", "+"],
                markers: ["=", "!", ":", "::"], // space here to support sprockets directives and flow comment types
                balanced: true,
              },
            },
          ],
        },
      }
    : { name: "custom/stylistic [inactive]" },

  {
    ...jsxA11yPlugin.flatConfigs.recommended,
    name: "plugin/jsx-a11y/recommended",
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/jsx-a11y",
        rules: {
          ...(jsxA11yPlugin.flatConfigs.recommended.rules ?? {}),
          "jsx-a11y/alt-text": [
            "warn",
            {
              elements: ["img", "object", "area", 'input[type="image"]'],
              img: ["Image"],
              object: [],
              area: [],
              'input[type="image"]': [],
            },
          ],
          "jsx-a11y/anchor-ambiguous-text": "off",
          "jsx-a11y/anchor-has-content": ["warn", { components: ["Link", "NextLink"] }],
          "jsx-a11y/anchor-is-valid": [
            "warn",
            {
              components: ["Link", "NextLink"],
              specialLink: ["to"],
              aspects: ["noHref", "invalidHref", "preferButton"],
            },
          ],
          "jsx-a11y/aria-activedescendant-has-tabindex": "warn",
          // Enforce all aria-* props are valid.
          "jsx-a11y/aria-props": "warn",
          // Enforce ARIA state and property values are valid.
          "jsx-a11y/aria-proptypes": "warn",
          // Require ARIA roles to be valid and non-abstract
          "jsx-a11y/aria-role": ["warn", { ignoreNonDOM: false }],
          "jsx-a11y/aria-unsupported-elements": "warn",
          "jsx-a11y/autocomplete-valid": ["warn", { inputComponents: [] }],
          "jsx-a11y/click-events-have-key-events": "warn",
          "jsx-a11y/control-has-associated-label": [
            "off",
            {
              labelAttributes: ["label"],
              controlComponents: [],
              ignoreElements: ["audio", "canvas", "embed", "input", "textarea", "tr", "video"],
              ignoreRoles: [
                "grid",
                "listbox",
                "menu",
                "menubar",
                "radiogroup",
                "row",
                "tablist",
                "toolbar",
                "tree",
                "treegrid",
              ],
              includeRoles: ["alert", "dialog"],
              depth: 5,
            },
          ],
          "jsx-a11y/heading-has-content": ["warn", { components: [""] }],
          "jsx-a11y/html-has-lang": "warn",
          "jsx-a11y/iframe-has-title": "warn",
          "jsx-a11y/img-redundant-alt": "warn",
          "jsx-a11y/interactive-supports-focus": [
            "warn",
            {
              tabbable: [
                "button",
                "checkbox",
                "link",
                "progressbar",
                "searchbox",
                "slider",
                "spinbutton",
                "switch",
                "textbox",
              ],
            },
          ],
          "jsx-a11y/label-has-associated-control": [
            "warn",
            {
              labelComponents: [
                // NOTE: app router
                // "FormLabel", // NOTE: <FormLabel /> gets id from context
                "Label",
                // NOTE: pages router
                "FormControlLabel",
                // "FormLabel",
                "InputLabel",
              ],
              labelAttributes: [],
              controlComponents: [
                // NOTE: app router
                "Button",
                "Checkbox",
                "Input",
                "RadioGroupItem",
                "Select",
                "Switch",
                "Textarea",
                // NOTE: pages router
                // "Button",
                // "Checkbox",
                // "Input",
                "Radio",
                // "Select",
                // "Switch",
                "TextField",
              ],
              assert: "either",
              depth: 25,
            },
          ],
          // require HTML element's lang prop to be valid
          "jsx-a11y/lang": "warn",
          "jsx-a11y/media-has-caption": [
            "warn",
            {
              audio: [],
              video: [],
              track: [],
            },
          ],
          "jsx-a11y/mouse-events-have-key-events": "off",
          "jsx-a11y/no-access-key": "warn",
          "jsx-a11y/no-aria-hidden-on-focusable": "off",
          "jsx-a11y/no-autofocus": ["warn", { ignoreNonDOM: true }],
          "jsx-a11y/no-distracting-elements": ["warn", { elements: ["marquee", "blink"] }],
          "jsx-a11y/no-interactive-element-to-noninteractive-role": [
            "warn",
            {
              tr: ["none", "presentation"],
              canvas: ["img"],
            },
          ],
          "jsx-a11y/no-noninteractive-element-interactions": [
            "warn",
            {
              handlers: [
                "onClick",
                "onError",
                "onLoad",
                "onMouseDown",
                "onMouseUp",
                "onKeyPress",
                "onKeyDown",
                "onKeyUp",
              ],
              alert: ["onKeyUp", "onKeyDown", "onKeyPress"],
              body: ["onError", "onLoad"],
              dialog: ["onKeyUp", "onKeyDown", "onKeyPress"],
              iframe: ["onError", "onLoad"],
              img: ["onError", "onLoad"],
            },
          ],
          "jsx-a11y/no-noninteractive-element-to-interactive-role": [
            "warn",
            {
              ul: ["listbox", "menu", "menubar", "radiogroup", "tablist", "tree", "treegrid"],
              ol: ["listbox", "menu", "menubar", "radiogroup", "tablist", "tree", "treegrid"],
              li: [
                "menuitem",
                "menuitemradio",
                "menuitemcheckbox",
                "option",
                "row",
                "tab",
                "treeitem",
              ],
              table: ["grid"],
              td: ["gridcell"],
              fieldset: ["radiogroup", "presentation"],
            },
          ],
          "jsx-a11y/no-noninteractive-tabindex": [
            "warn",
            {
              tags: [],
              roles: ["tabpanel"],
              allowExpressionValues: true,
            },
          ],
          "jsx-a11y/no-redundant-roles": ["warn", { nav: ["navigation"] }],
          "jsx-a11y/no-static-element-interactions": [
            "warn",
            {
              allowExpressionValues: true,
              handlers: [
                "onClick",
                "onMouseDown",
                "onMouseUp",
                "onKeyPress",
                "onKeyDown",
                "onKeyUp",
              ],
            },
          ],
          "jsx-a11y/prefer-tag-over-role": "off",
          "jsx-a11y/role-has-required-aria-props": "warn",
          "jsx-a11y/role-supports-aria-props": "warn",
          // only allow <th> to have the "scope" attr
          "jsx-a11y/scope": "warn",
          "jsx-a11y/tabindex-no-positive": "warn",
        },
      }
    : { name: "custom/jsx-a11y [inactive]" },

  {
    // TODO:#i# change to 'recommended' when v6 releases
    ...reactHooks.configs["recommended-latest"],
    name: "plugin/react-hooks/recommended",
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/react-hooks",
        files: ["**/*.{jsx,tsx}"],
        rules: {
          // TODO:#i# change to 'recommended' when v6 releases
          ...reactHooks.configs["recommended-latest"].rules,
          "react-hooks/rules-of-hooks": "error",
          "react-hooks/exhaustive-deps": [
            "error",
            { additionalHooks: "(useAsync|useUpdateEffect)" },
          ],
        },
      }
    : { name: "custom/react-hooks [inactive]" },

  {
    ...reactCompiler.configs.recommended,
    name: "plugin/react-compiler/recommended",
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.EXPENSIVE_REACT_COMPILER)
    ? {
        name: "custom/react-compiler",
        files: ["**/*.{jsx,tsx}"],
        rules: {
          ...reactCompiler.configs.recommended.rules,
          "react-compiler/react-compiler": "error",
        },
      }
    : { name: "custom/react-compiler [inactive]" },

  {
    ...reactPlugin.configs.flat.recommended,
    name: "plugin/react/recommended",
    settings: {
      react: {
        version: "detect",
      },
    },
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/react",
        files: ["**/*.{jsx,tsx}"],
        rules: {
          ...(reactPlugin.configs.flat.recommended.rules ?? {}),
          "react/button-has-type": [
            "error",
            {
              button: true,
              submit: true,
              reset: false,
            },
          ],
          "react/checked-requires-onchange-or-readonly": "warn",
          "react/destructuring-assignment": [
            "error",
            "always",
            { ignoreClassFields: true, destructureInSignature: "always" },
          ],
          "react/display-name": "warn",
          "react/function-component-definition": [
            "warn",
            {
              namedComponents: "arrow-function",
              unnamedComponents: ["function-expression", "arrow-function"],
            },
          ],
          "react/iframe-missing-sandbox": "warn",
          "react/jsx-boolean-value": ["error", "never", { always: [] }],
          "react/jsx-curly-brace-presence": ["error", { props: "never", children: "never" }],
          "react/jsx-filename-extension": ["error", { extensions: [".jsx", ".tsx"] }],
          "react/jsx-fragments": ["error", "syntax"],
          "react/jsx-key": "off", // NOTE: Turned off because too many false positives; react errors are logged if it's missing
          "react/jsx-no-bind": [
            "error",
            {
              ignoreRefs: true,
              allowArrowFunctions: true,
              allowFunctions: false,
              allowBind: false,
              ignoreDOMComponents: true,
            },
          ],
          "react/jsx-no-comment-textnodes": "error",
          "react/jsx-no-constructed-context-values": "error",
          "react/jsx-no-duplicate-props": ["error", { ignoreCase: true }],
          "react/jsx-no-leaked-render": "warn",
          "react/jsx-no-target-blank": ["warn", { enforceDynamicLinks: "always" }], // NOTE: 'off' in nextJS config
          "react/jsx-no-undef": "error",
          "react/jsx-no-useless-fragment": "error",
          "react/jsx-pascal-case": [
            "error",
            {
              allowAllCaps: true,
              ignore: [],
            },
          ],
          "react/jsx-props-no-spreading": [
            "error",
            { exceptions: ["WrappedComponent", "Input", "Textarea", "StarRating"] },
          ],
          "react/jsx-sort-props": [
            "off",
            {
              ignoreCase: true,
              callbacksLast: false,
              shorthandFirst: false,
              shorthandLast: false,
              noSortAlphabetically: false,
              reservedFirst: true,
            },
          ],
          "react/jsx-uses-react": "error",
          "react/jsx-uses-vars": "error",
          "react/no-access-state-in-setstate": "error",
          "react/no-array-index-key": "error",
          "react/no-arrow-function-lifecycle": "error",
          "react/no-children-prop": "error",
          "react/no-danger-with-children": "error",
          "react/no-danger": "warn",
          "react/no-deprecated": "error",
          "react/no-did-update-set-state": "error",
          "react/no-direct-mutation-state": "error",
          "react/no-find-dom-node": "error",
          "react/no-invalid-html-attribute": "error",
          "react/no-is-mounted": "error",
          "react/no-namespace": "error",
          "react/no-object-type-as-default-prop": "error",
          "react/no-redundant-should-component-update": "error",
          "react/no-render-return-value": "error",
          "react/no-string-refs": "error",
          "react/no-this-in-sfc": "error",
          "react/no-typos": "error",
          "react/no-unescaped-entities": "error",
          "react/no-unknown-property": "warn", // NOTE: 'off' in nextJS config
          "react/no-unsafe": "off",
          "react/no-unstable-nested-components": "error",
          "react/no-unused-class-component-methods": "error",
          "react/no-unused-prop-types": [
            "error",
            {
              customValidators: [],
              skipShapeProps: true,
            },
          ],
          "react/no-unused-state": "error",
          "react/no-will-update-set-state": "error",
          "react/prefer-es6-class": ["error", "always"],
          "react/prefer-read-only-props": "error",
          "react/prefer-stateless-function": ["error", { ignorePureComponents: true }],
          "react/prop-types": [
            "error",
            {
              ignore: [],
              customValidators: [],
              skipUndeclared: false,
            },
          ],
          "react/react-in-jsx-scope": "off",
          "react/require-default-props": ["off", { forbidDefaultForRequired: true }],
          "react/require-render-return": "error",
          "react/self-closing-comp": "error",
          "react/sort-comp": [
            "warn",
            {
              order: [
                "static-variables",
                "static-methods",
                "instance-variables",
                "lifecycle",
                "/^handle.+$/",
                "/^on.+$/",
                "getters",
                "setters",
                "/^(get|set)(?!(InitialState$|DefaultProps$|ChildContext$)).+$/",
                "instance-methods",
                "everything-else",
                "rendering",
              ],
              groups: {
                lifecycle: [
                  "displayName",
                  "propTypes",
                  "contextTypes",
                  "childContextTypes",
                  "mixins",
                  "statics",
                  "defaultProps",
                  "constructor",
                  "getDefaultProps",
                  "getInitialState",
                  "state",
                  "getChildContext",
                  "getDerivedStateFromProps",
                  "componentWillMount",
                  "UNSAFE_componentWillMount",
                  "componentDidMount",
                  "componentWillReceiveProps",
                  "UNSAFE_componentWillReceiveProps",
                  "shouldComponentUpdate",
                  "componentWillUpdate",
                  "UNSAFE_componentWillUpdate",
                  "getSnapshotBeforeUpdate",
                  "componentDidUpdate",
                  "componentDidCatch",
                  "componentWillUnmount",
                ],
                rendering: ["/^render.+$/", "render"],
              },
            },
          ],
          "react/sort-default-props": ["warn", { ignoreCase: false }],
          "react/state-in-constructor": ["error", "never"],
          "react/static-property-placement": ["error", "static public field"],
          "react/style-prop-object": "error",
          "react/void-dom-elements-no-children": "error",
        },
      }
    : { name: "custom/react [inactive]" },

  {
    name: "plugin/typescript",
    plugins: {
      "@typescript-eslint": tsEslintPlugin,
    },
    languageOptions: {
      ...tsEslintConfigs.base.languageOptions,
      parserOptions: {
        projectService: true,
        tsconfigRootDir: __dirname,
      },
    },
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/typescript/normal",
        rules: {
          ...tsEslintConfigs.eslintRecommended.rules,
          ...(tsEslintConfigs.strict.at(-1)?.rules ?? {}),
          ...(tsEslintConfigs.stylistic.at(-1)?.rules ?? {}),
          "@typescript-eslint/consistent-type-definitions": "off",
          "@typescript-eslint/explicit-function-return-type": ["off", { allowExpressions: true }],
          "@typescript-eslint/no-inferrable-types": "off",
          "no-unused-vars": "off",
          "@typescript-eslint/no-unused-vars": [
            "warn",
            {
              vars: "all",
              varsIgnorePattern: "^_",
              args: "after-used",
              argsIgnorePattern: "^_",
              ignoreRestSiblings: true,
              destructuredArrayIgnorePattern: "^_",
            },
          ],
          "no-use-before-define": "off",
          "@typescript-eslint/no-use-before-define": ["error"],
          "no-shadow": "off",
          "@typescript-eslint/no-shadow": ["error"],
        },
      }
    : { name: "custom/typescript/normal [inactive]" },

  RULESETS_TO_RUN.has(RULESET.EXPENSIVE_TYPECHECKED)
    ? {
        name: "custom/typescript/type-checked",
        rules: {
          ...(tsEslintConfigs.strictTypeCheckedOnly.at(-1)?.rules ?? {}),
          ...(tsEslintConfigs.stylisticTypeCheckedOnly.at(-1)?.rules ?? {}),
          "@typescript-eslint/no-confusing-void-expression": [
            "error",
            { ignoreArrowShorthand: true },
          ],
          "import-x/no-deprecated": "off",
          "@typescript-eslint/no-deprecated": "error",
          "require-await": "off", // NOTE: using equivalent from @typescript-eslint
          "@typescript-eslint/require-await": "off",
          "@typescript-eslint/restrict-template-expressions": [
            "warn",
            { allowBoolean: true, allowNullish: true },
          ],
          "@typescript-eslint/unbound-method": "error",
        },
      }
    : { name: "custom/typescript/type-checked [inactive]" },

  {
    ...jestPlugin.configs["flat/recommended"],
    name: "plugin/jest/recommended",
    files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
    rules: {},
  },

  {
    ...jestPlugin.configs["flat/style"],
    name: "plugin/jest/style",
    files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
    rules: {},
  },

  {
    name: "custom/jest/normal",
    files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
    rules: {
      ...(jestPlugin.configs["flat/recommended"].rules ?? {}),
      ...(jestPlugin.configs["flat/style"].rules ?? {}),
      "jest/consistent-test-it": "error",
      "jest/prefer-spy-on": "error",
    },
  },

  RULESETS_TO_RUN.has(RULESET.EXPENSIVE_TYPECHECKED)
    ? {
        name: "custom/jest/type-checked",
        files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
        rules: {
          "@typescript-eslint/unbound-method": "off",
          "jest/unbound-method": "error",
        },
      }
    : { name: "custom/jest/type-checked [inactive]" },

  {
    ...jestDomPlugin.configs["flat/recommended"],
    name: "plugin/jest-dom/recommended",
    files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/jest-dom",
        files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
        rules: {
          ...(jestDomPlugin.configs["flat/recommended"].rules ?? {}),
        },
      }
    : { name: "custom/jest-dom [inactive]" },

  {
    ...testingLibraryPlugin.configs["flat/react"],
    name: "plugin/testing-library/react",
    files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/testing-library/react",
        files: ["src/**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}"],
        rules: {
          ...(testingLibraryPlugin.configs["flat/react"].rules ?? {}),
        },
      }
    : { name: "custom/testing-library/react [inactive]" },

  {
    ...cypressPlugin.configs.recommended,
    name: "plugin/cypress/recommended",
    files: ["cypress/**"],
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/cypress",
        files: ["cypress/**"],
        rules: {
          ...(cypressPlugin.configs.recommended.rules ?? {}),
          "cypress/no-assigning-return-values": "error",
          "cypress/no-unnecessary-waiting": "error",
          "cypress/assertion-before-screenshot": "warn",
          "cypress/no-force": "warn",
          "cypress/no-async-tests": "error",
          "cypress/no-pause": "error",
          "cypress/require-data-selectors": "warn",
        },
      }
    : { name: "custom/cypress [inactive]" },

  {
    ...chaiFriendlyPlugin.configs.recommendedFlat,
    name: "plugin/chai-friendly/recommended",
    files: ["cypress/**"],
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/chai-friendly",
        files: ["cypress/**"],
        rules: {
          ...(chaiFriendlyPlugin.configs.recommendedFlat.rules ?? {}),
        },
      }
    : { name: "custom/chai-friendly [inactive]" },

  {
    ...mochaPlugin.configs.recommended,
    name: "plugin/mocha/recommended",
    files: ["cypress/**"],
    rules: {},
  },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/mocha",
        files: ["cypress/**"],
        rules: {
          ...(mochaPlugin.configs.recommended.rules ?? {}),
          "mocha/consistent-spacing-between-blocks": "off",
          "mocha/max-top-level-suites": "off",
          "mocha/no-mocha-arrows": "off",
          "mocha/no-setup-in-describe": "off", // NOTE: creates false positives with `[].forEach(...)`
          "prefer-arrow-callback": "off",
          "mocha/prefer-arrow-callback": [
            "error",
            {
              allowNamedFunctions: true,
              allowUnboundThis: true,
            },
          ],
        },
      }
    : { name: "custom/mocha [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/test-files",
        files: [
          "**/*.{test,spec}.{js,cjs,mjs,jsx,ts,cts,mts,tsx}",
          "testing-frontend/**",
          "cypress/**",
        ],
        rules: {
          "import-x/no-extraneous-dependencies": "off",
          "n/no-extraneous-import": ["error", { allowModules: ["user_roles", "test-utils"] }],
          "import-x/no-namespace": "off",
          "import-x/no-nodejs-modules": "off",
        },
      }
    : { name: "custom/exception/test-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/mock-files",
        files: ["**/__mocks__/**"],
        rules: {
          "import-x/prefer-default-export": "off",
        },
      }
    : { name: "custom/exception/mock-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/allow-prop-spread-in-base-components",
        files: ["src/components/ui/**", "src/hoc/**", "**/_app.tsx", "**/_document.tsx"],
        rules: {
          "react/jsx-props-no-spreading": "off",
        },
      }
    : { name: "custom/exception/allow-prop-spread-in-base-components [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/pages-api-route-handler-files",
        files: ["src/pages/api/**/*.{ts,tsx}"],
        rules: {
          "import-x/no-nodejs-modules": "off",
        },
      }
    : { name: "custom/exception/pages-api-route-handler-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/type-declaration-files",
        files: ["**/*.d.ts"],
        rules: {
          "no-unused-vars": "off",
          "@typescript-eslint/no-unused-vars": "off",
        },
      }
    : { name: "custom/exception/type-declaration-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/cjs-files",
        files: ["**/*.cjs", "vendored/**/*.js"],
        rules: {
          "@typescript-eslint/no-require-imports": "off",
        },
      }
    : { name: "custom/exception/cjs-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/config-files",
        files: ["**/*.config.{js,cjs,mjs,ts,cts,mts}"],
        rules: {
          "import-x/no-extraneous-dependencies": "off",
          "import-x/no-nodejs-modules": "off",
        },
      }
    : { name: "custom/exception/config-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/script-files",
        files: ["scripts/*.mjs", "translations/*.mjs"],
        rules: {
          "n/hashbang": [
            "warn",
            {
              ignoreUnpublished: true,
              additionalExecutables: ["scripts/*.mjs", "translations/*.mjs"],
            },
          ],
          "no-console": "off",
          "import-x/no-nodejs-modules": "off",
        },
      }
    : { name: "custom/exception/script-files [inactive]" },

  RULESETS_TO_RUN.has(RULESET.NORMAL)
    ? {
        name: "custom/exception/next-env-type-file",
        files: ["next-env.d.ts"],
        rules: {
          "@typescript-eslint/triple-slash-reference": "off",
        },
      }
    : { name: "custom/exception/next-env-type-file [inactive]" },
] satisfies EslintConfigArray;

export default eslintConfig;
