import React from 'react'
import styles from '../styles/examples.module.scss'
import Prism from 'prismjs'
import 'prismjs/components/prism-rust'
import 'prismjs/components/prism-python'
import '../styles/vs-code-theme.css'

interface Benchmark {
  metric: string;
  rust: string;
  buzz: string;
  diff: string;
}

interface CodeExample {
  rust: string;
  buzz: string;
  benchmarks: Benchmark[];
}

interface CodeBlockProps {
  title?: string;
  code: CodeExample;
  language?: string;
}

export const CodeBlock: React.FC<CodeBlockProps> = ({
  title,
  code,
  language = "buzz"
}) => {
  React.useEffect(() => {
    Prism.highlightAll()
  }, [code])

  return (
    <div className={styles.container}>
      {title && (
        <h3 className={styles.h3}><span>{title}</span></h3>
      )}
      <div className={styles.columns}>
        <div className={styles.column}>
          <div className={styles.box}>
            <div className={styles.label}>RUST</div>
            <pre className={styles.pre}>
              <code className="language-rust">{code.rust}</code>
            </pre>
          </div>
        </div>
        <div className={styles.column}>
          <div className={styles.box}>
            <div className={styles.label}>BUZZ</div>
            <pre className={styles.pre}>
              <code className="language-python">{code.buzz}</code>
            </pre>
          </div>
        </div>
      </div>
      <table className={styles.table}>
        <thead>
          <tr>
            <th>METRIC</th>
            <th>RUST</th>
            <th>BUZZ</th>
            <th>DIFF</th>
          </tr>
        </thead>
        <tbody>
          {code.benchmarks.map((benchmark, index) => (
            <tr key={index}>
              <td>{benchmark.metric}</td>
              <td>{benchmark.rust}</td>
              <td>{benchmark.buzz}</td>
              <td>{benchmark.diff}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
