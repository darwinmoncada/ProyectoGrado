import { createContext, useContext, useCallback, useMemo, useState } from 'react';

const STORAGE_KEY = 'inventario-theme-mode';

const ThemeModeContext = createContext({ mode: 'light', toggleColorMode: () => {} });

export function ThemeModeProvider({ children }) {
  const [mode, setMode] = useState(() => localStorage.getItem(STORAGE_KEY) === 'dark' ? 'dark' : 'light');

  const toggleColorMode = useCallback(() => {
    setMode((prev) => {
      const next = prev === 'light' ? 'dark' : 'light';
      localStorage.setItem(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const value = useMemo(() => ({ mode, toggleColorMode }), [mode, toggleColorMode]);

  return <ThemeModeContext.Provider value={value}>{children}</ThemeModeContext.Provider>;
}

export function useThemeMode() {
  return useContext(ThemeModeContext);
}
