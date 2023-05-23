import path from "path";
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import typescript from "@rollup/plugin-typescript";
import url from '@rollup/plugin-url';
import inject from '@rollup/plugin-inject';
import dts from "rollup-plugin-dts";

import packageJson from "./package.json" assert { type: "json" };

export default [
  {
    input: "src/index.ts",
    output: [
      {
        file: packageJson.main,
        format: "cjs",
        sourcemap: true,
      },
      {
        file: packageJson.module,
        format: "esm",
        sourcemap: true,
      },
    ],
    plugins: [
      inject({
        "flutter": path.resolve("./flutter", "flutter.js"),
      }),
      url({
        fileName: '[dirname][hash][extname]',
        sourceDir: path.resolve('./flutter')
      }),
      resolve(),
      commonjs(),
      typescript({ tsconfig: "./tsconfig.json" }),
    ],
  },
  {
    input: "dist/esm/types/index.d.ts",
    output: [{ file: "dist/index.d.ts", format: "esm" }],
    plugins: [dts()],
  },
];