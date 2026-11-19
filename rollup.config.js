import resolve from "@rollup/plugin-node-resolve"
import commonjs from '@rollup/plugin-commonjs';

// Known-harmless warnings from dependencies, silenced so real warnings stand out
const ignoredWarning = (warning) => {
  const id = warning.id || ''

  // TypeScript's emitted helpers (`this && this.__classPrivateFieldGet`) are written to handle `this` being undefined
  if (warning.code === 'THIS_IS_UNDEFINED' && id.includes('/node_modules/')) return true

  // Spotlight falls back to `bootstrap.default?.X` for CDN builds; the named export is used with Bootstrap's ESM build
  if (warning.code === 'MISSING_EXPORT' && warning.binding === 'default' &&
      id.includes('/node_modules/spotlight-frontend/') && warning.exporter?.includes('/node_modules/bootstrap/')) return true

  return false
}

export default {
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "esm",
    inlineDynamicImports: true,
    sourcemap: true,
   	globals : {}
  },
  plugins: [
    resolve(),
    commonjs()
  ],
  external: [],
  onwarn(warning, warn) {
    if (ignoredWarning(warning)) return

    warn(warning)
  }
}
