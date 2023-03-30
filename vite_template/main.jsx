import * as React from 'react';
import ReactDOM from 'react-dom/client';
import { RouterProvider, createBrowserRouter } from 'react-router-dom';
import { routesApp } from './app/index.js';

const router = createBrowserRouter([
  {
    path: '/',
    children: routesApp,
  }
]);

ReactDOM.createRoot(
  document.getElementById('root')
).render(
  <React.StrictMode>
    <RouterProvider router={router}/>
  </React.StrictMode>
);
