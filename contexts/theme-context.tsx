"use client"

import type React from "react"
import { createContext, useContext, useEffect, useState } from "react"

type Theme = "dark" | "light" | "system"

type ThemeProviderProps = {
  children: React.ReactNode
  defaultTheme?: Theme
  storageKey?: string
  attribute?: string
  enableSystem?: boolean
  disableTransitionOnChange?: boolean
}

type ThemeProviderState = {
  theme: Theme
  setTheme: (theme: Theme) => void
  resolvedTheme: "dark" | "light"
  isLoading: boolean
  toggleTheme: () => void
}

const initialState: ThemeProviderState = {
  theme: "system",
  setTheme: () => null,
  resolvedTheme: "light",
  isLoading: true,
  toggleTheme: () => null,
}

const ThemeProviderContext = createContext<ThemeProviderState>(initialState)

export function ThemeProvider({
  children,
  defaultTheme = "system",
  storageKey = "ui-theme",
  attribute = "class",
  enableSystem = true,
  disableTransitionOnChange = false,
  ...props
}: ThemeProviderProps) {
  const [theme, setTheme] = useState<Theme>(defaultTheme)
  const [resolvedTheme, setResolvedTheme] = useState<"dark" | "light">("light")
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    try {
      const storedTheme = localStorage.getItem(storageKey) as Theme
      if (storedTheme) {
        setTheme(storedTheme)
      }
    } catch (error) {
      console.warn("Failed to read theme from localStorage:", error)
    }
    setIsLoading(false)
  }, [storageKey])

  useEffect(() => {
    const root = window.document.documentElement

    root.classList.remove("light", "dark")

    let systemTheme: "dark" | "light" = "light"

    try {
      if (enableSystem && theme === "system") {
        systemTheme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
      }
    } catch (error) {
      console.warn("Failed to detect system theme:", error)
    }

    const resolvedTheme = theme === "system" ? systemTheme : theme
    setResolvedTheme(resolvedTheme)

    if (attribute === "class") {
      root.classList.add(resolvedTheme)
    } else {
      root.setAttribute(attribute, resolvedTheme)
    }
  }, [theme, attribute, enableSystem])

  const toggleTheme = () => {
    const newTheme = resolvedTheme === "dark" ? "light" : "dark"
    try {
      localStorage.setItem(storageKey, newTheme)
    } catch (error) {
      console.warn("Failed to save theme to localStorage:", error)
    }
    setTheme(newTheme)
  }

  const value = {
    theme,
    setTheme: (theme: Theme) => {
      try {
        localStorage.setItem(storageKey, theme)
      } catch (error) {
        console.warn("Failed to save theme to localStorage:", error)
      }
      setTheme(theme)
    },
    resolvedTheme,
    isLoading,
    toggleTheme,
  }

  return (
    <ThemeProviderContext.Provider {...props} value={value}>
      {children}
    </ThemeProviderContext.Provider>
  )
}

export const useTheme = () => {
  const context = useContext(ThemeProviderContext)

  if (context === undefined) {
    console.warn("useTheme must be used within a ThemeProvider")
    return initialState
  }

  return context
}

// Safe theme provider with error boundary
export function SafeThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <ThemeProvider {...props}>{children}</ThemeProvider>
}
