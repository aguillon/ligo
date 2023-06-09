import React, { useEffect, useState } from "react";
import SyntaxContext from "@theme/Syntax/SyntaxContext";

// Default implementation, that you can customize
export default function Root({ children }) {
  const [syntax, setSyntax] = useState(() => {
    if (typeof window === "undefined") return "jsligo";

    const syntax = localStorage.getItem("syntax");

    const params = new Proxy(new URLSearchParams(window.location.search), {
      get: (searchParams, prop) => searchParams.get(prop),
    });

    // Remove "pascaligo" after 0.60.0 doc is deleted
    const valid = ["jsligo", "cameligo", "pascaligo"];

    const lang = (params.lang || "").toLowerCase();

    if (valid.includes(lang)) return lang;

    return syntax ?? "jsligo";
  });

  useEffect(() => {
    const params = new Proxy(new URLSearchParams(window.location.search), {
      get: (searchParams, prop) => searchParams.get(prop),
    });

    if (!!params.lang) return;

    const url = new URL(window.location);
    url.searchParams.set("lang", syntax);
    window.history.replaceState(null, "", url.toString());
  });

  return (
    <SyntaxContext.Provider value={{ syntax, setSyntax }}>
      {children}
    </SyntaxContext.Provider>
  );
}
