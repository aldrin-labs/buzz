import React from 'react'
import { Text, Container } from './sacred'
import ReactPrism from '@uiw/react-prismjs'
import 'prismjs/plugins/line-numbers/prism-line-numbers'
import 'prismjs/plugins/line-numbers/prism-line-numbers.css'
import '../styles/vs-code-theme.css'
import '../lib/prism-buzz'
import '../styles/code-block.css'

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
  return (
    <Container style={{
      border: '1px solid var(--theme-border)',
      overflow: 'hidden',
      background: 'var(--vscode-background)',
      boxShadow: 'var(--theme-shadow)',
      borderRadius: '8px',
      width: '100%',
      maxWidth: '100%',
      margin: '5rem auto',
      padding: '3.5rem'
    }}>
      {title && (
        <Text variant="h3" color="secondary" style={{ marginBottom: '1.5rem' }}>
          {title}
        </Text>
      )}
      <div style={{ overflow: 'auto' }}>
        <ReactPrism
          language={language}
          className="code-block line-numbers"
          source={code}
          prefixCls="w-prismjs"
        />
      </div>
    </Container>
  )
}
