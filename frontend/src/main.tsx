import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';

createRoot(document.getElementById('root')!).render(
  // Temporarily disabled StrictMode for debugging authentication issues
  // <StrictMode>
    <App />
  // </StrictMode>
);
