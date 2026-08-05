import type { Config } from 'jest';

const config: Config = {
  moduleFileExtensions: ['js', 'json', 'ts', 'mjs'],
  rootDir: '.',
  testEnvironment: 'node',
  testRegex: '.e2e-spec.ts$',
  transform: {
    '^.+\\.(t|j)sx?$': [
      'ts-jest',
      {
        tsconfig: {
          allowJs: true,
          esModuleInterop: true,
        },
      },
    ],
  },
  transformIgnorePatterns: ['node_modules/(?!.*(@noble|bs58|base-x)/)'],
  testTimeout: 60_000,
  maxWorkers: 1,
};

export default config;
