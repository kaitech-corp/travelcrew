const js = require("@eslint/js");
const globals = require("globals");
module.exports = [
  {ignores: ["node_modules/**"]},
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: globals.node,
    },
    rules: {"quotes": ["error", "double", {avoidEscape: true}]},
  },
];
