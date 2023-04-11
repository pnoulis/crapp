import * as React from "react";
import { App } from "./App.jsx";
import { RouteHome } from "./route_home/index.js";

const routesApp = [
  {
    path: "/",
    element: <App />,
    children: [
      {
        path: "/",
        element: <RouteHome />,
      },
    ],
  },
];

export { routesApp };
