// https://docs.expo.dev/guides/using-eslint/
const { defineConfig } = require('eslint/config');
const expoConfig = require("eslint-config-expo/flat");

module.exports = defineConfig([
  expoConfig,
  {
    ignores: ["dist/*"],
  },
  {
    // Reglas del React Compiler que marcan patrones FUNCIONALES y comunes
    // (prefill/sync de estado en efectos al montar/abrir; ids con Date.now en
    // handlers). Se dejan como warning para no bloquear: el refactor debe hacerse
    // con pruebas visuales en dev build, no a ciegas antes del store.
    rules: {
      "react-hooks/set-state-in-effect": "warn",
      "react-hooks/purity": "warn",
    },
  },
]);
