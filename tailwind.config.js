/** @type {import('tailwindcss').Config} */
const palette = [
  "sky",
  "cyan",
  "teal",
  "emerald",
  "green",
  "lime",
  "amber",
  "yellow",
  "orange",
  "rose",
  "pink",
  "red",
  "fuchsia",
  "purple",
  "violet",
  "indigo",
  "blue",
];

function liquidColorSafelist() {
  const out = new Set();
  for (const c of palette) {
    [
      `bg-${c}-100`,
      `dark:bg-${c}-900/30`,
      `text-${c}-600`,
      `dark:bg-${c}-950/50`,
      `text-${c}-900`,
      `dark:text-${c}-100`,
    ].forEach((cls) => out.add(cls));
  }
  [
    "bg-slate-100",
    "dark:bg-slate-800",
    "text-slate-700",
    "bg-slate-200",
    "text-slate-900",
    "dark:text-slate-100",
    "text-amber-950",
  ].forEach((cls) => out.add(cls));
  return [...out];
}

module.exports = {
  darkMode: "class",
  content: [
    "./_layouts/**/*.html",
    "./_includes/**/*.html",
    "./*.html",
    "./admin/index.html",
    "./404.html",
    "./assets/js/search-init.js",
  ],
  safelist: liquidColorSafelist(),
  theme: {
    extend: {
      colors: {
        primary: "#da1b5b",
        "primary-dark": "#b9154a",
        "background-light": "#fbf8f9",
        "background-dark": "#211116",
        "surface-light": "#ffffff",
        "surface-dark": "#2d1b22",
      },
      fontFamily: {
        display: ["Plus Jakarta Sans", "sans-serif"],
      },
      borderRadius: {
        DEFAULT: "0.5rem",
        lg: "1rem",
        xl: "1.5rem",
        full: "9999px",
      },
      boxShadow: {
        soft: "0 4px 20px -2px rgba(0, 0, 0, 0.05)",
        hover:
          "0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)",
      },
      screens: {
        xs: "480px",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/container-queries"),
    require("@tailwindcss/typography"),
  ],
};
