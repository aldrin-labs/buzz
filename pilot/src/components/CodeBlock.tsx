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
        <ReactPrism
          language={language}
          className="code-block line-numbers"
          source={code}
          prefixCls="w-prismjs"
        />
      </Container>
    </Container>
  )
}
