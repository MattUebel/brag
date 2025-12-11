/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `add-brag` command */
  export type AddBrag = ExtensionPreferences & {}
  /** Preferences accessible in the `search-brags` command */
  export type SearchBrags = ExtensionPreferences & {}
  /** Preferences accessible in the `recent-brags` command */
  export type RecentBrags = ExtensionPreferences & {}
  /** Preferences accessible in the `export-brags` command */
  export type ExportBrags = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `add-brag` command */
  export type AddBrag = {}
  /** Arguments passed to the `search-brags` command */
  export type SearchBrags = {}
  /** Arguments passed to the `recent-brags` command */
  export type RecentBrags = {}
  /** Arguments passed to the `export-brags` command */
  export type ExportBrags = {}
}

