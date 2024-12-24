import React, { useEffect, useRef } from 'react'
import { Text, Container } from './sacred'
import Prism from 'prismjs'
import 'prismjs/plugins/line-numbers/prism-line-numbers'
import 'prismjs/plugins/line-numbers/prism-line-numbers.css'
import '../styles/vs-code-theme.css'
import '../lib/prism-buzz'

interface CodeBlockProps {
  title?: string
  code: string
  language?: string
}

export const CodeBlock: React.FC<CodeBlockProps> = ({
  title,
  code,
  language = "buzz"
}) => {
  const preRef = useRef<HTMLPreElement>(null)
  const codeRef = useRef<HTMLElement>(null)

  useEffect(() => {
    if (typeof window !== 'undefined') {
      Prism.manual = true
    }

    if (codeRef.current && preRef.current) {
      const formattedCode = code
        .split('\n')
        .map((line) => {
          if (line.trim() === '') return ''
          const indent = line.search(/\S/)
          if (indent === -1) return line
          const spaces = ' '.repeat(Math.floor(indent / 2) * 2)
          return spaces + line.trim()
        })
        .join('\n')
        .trim()

      codeRef.current.innerHTML = formattedCode
      preRef.current.className = `language-${language} line-numbers`
      codeRef.current.className = `language-${language}`

      requestAnimationFrame(() => {
        if (codeRef.current) {
          Prism.highlightElement(codeRef.current as HTMLElement)
        }
      })
    }
  }, [code, language])

  return (
    <Container style={{ width: '100%', padding: 0, background: 'transparent', boxShadow: 'none' }}>
      {title && (
        <Text variant="h3" color="secondary" style={{ marginBottom: '1ch' }}>
          {title}
        </Text>
      )}
      <Container style={{
        border: '1px solid var(--theme-border)',
        overflow: 'hidden',
        background: 'var(--vscode-background)',
        boxShadow: 'var(--theme-shadow)',
        borderRadius: '8px',
        width: '100%',
        maxWidth: '100%',
        margin: '0 auto',
        padding: 0
      }}>
        <pre
          ref={preRef}
          className={`language-${language} line-numbers`}
          style={{
            margin: 0,
            background: 'transparent',
            padding: '1.5rem',
            width: '100%',
            overflowX: 'auto',
            fontSize: '0.9rem',
            lineHeight: '1.5'
          }}
          data-start="1"
        >
          <code
            ref={codeRef}
            className={`language-${language}`}
            style={{
              whiteSpace: 'pre',
              tabSize: 2,
              background: 'transparent',
              fontFamily: 'var(--font-family-mono, monospace)',
              fontSize: 'inherit',
              lineHeight: 'inherit',
              color: 'var(--theme-text)',
              display: 'block',
              width: '100%'
            }}
          >
            {code}
          </code>
        </pre>
      </Container>
    </Container>
  )
}
