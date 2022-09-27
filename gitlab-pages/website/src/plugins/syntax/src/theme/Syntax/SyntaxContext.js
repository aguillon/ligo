import React from "react";

const params = new Proxy(new URLSearchParams(window.location.search), {
  get: (searchParams, prop) => searchParams.get(prop),
});

const valid = ["jsligo", "cameligo", "reasonligo", "pascaligo"];

const ctx = {
  syntax: (() => {
    const lang = (params.lang || "").toLowerCase();

    if (valid.includes(lang)) return lang;

    return "jsligo";
  })(),
  setSyntax: () => {},
};

const SyntaxContext = React.createContext(ctx);

export default SyntaxContext;
