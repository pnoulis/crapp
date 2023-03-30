import * as React from 'react';
import { App } from "./App.jsx";
import { Scratch } from './Scratch.jsx';
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
      {
        path: "/scratch",
        element: <Scratch />,
      },
    ],
  },
];

export { routesApp };
