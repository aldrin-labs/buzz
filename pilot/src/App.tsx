import { DefaultActionBar, Grid, Text, Container } from './components/sacred'
import { CodeBlock } from "./components/CodeBlock"
import { securityExample, aiExample, syntaxExample, solanaExample } from "./lib/code-examples"
import { Link } from 'react-router-dom'
import styles from './App.module.scss'

const App: React.FC = () => {
  return (
    <div className="app">
      <DefaultActionBar
        items={[
          {
            hotkey: '',
            onClick: () => {},
            body: 'BUZZ LANG'
          },
          {
            hotkey: '',
            onClick: () => {},
            body: <Link to="/docs">DOCS</Link>
          },
          {
            hotkey: '',
            onClick: () => {},
            body: <Link to="/create-dao">CREATE DAO</Link>
          }
        ]}
      />

      <Container isMain>
        <Grid>
          <div className={styles.heroSection}>
            <Text variant="h1" style={{
              fontSize: '48px',
              color: 'var(--theme-headline-main)',
              marginBottom: '1.5rem'
            }}>
              The Language for Solana Smart Contracts
            </Text>
            <Text style={{
              fontSize: '20px',
              color: 'var(--theme-text-secondary)',
              maxWidth: '60ch',
              margin: '0 auto'
            }}>
              Write secure, efficient, and maintainable Solana programs with Python-like syntax.
            </Text>
          </div>

          <div className={styles.featuresSection}>
            <Text variant="h2" style={{
              color: 'var(--theme-headline)',
              textAlign: 'center',
              marginBottom: '4rem'
            }}>
              Features
            </Text>

            <div className={styles.featureCards}>
              <Container className={styles.featureCard}>
                <Text variant="h3" color="secondary">Security First</Text>
                <Text color="secondary">
                  Built-in decorators for ownership verification and reentrancy protection.
                </Text>
                <CodeBlock code={securityExample} language="python" />
              </Container>

              <Container className={styles.featureCard}>
                <Text variant="h3" color="secondary">AI Ready</Text>
                <Text color="secondary">
                  First-class support for on-chain AI agents and autonomous programs.
                </Text>
                <CodeBlock code={aiExample} language="python" />
              </Container>

              <Container className={styles.featureCard}>
                <Text variant="h3" color="secondary">Clean Syntax</Text>
                <Text color="secondary">
                  Python-like syntax for writing smart contracts.
                </Text>
                <CodeBlock code={syntaxExample} language="python" />
              </Container>

              <Container className={styles.featureCard}>
                <Text variant="h3" color="secondary">Solana Native</Text>
                <Text color="secondary">
                  Native Solana integration with built-in account management.
                </Text>
                <CodeBlock code={solanaExample} language="python" />
              </Container>
            </div>
          </div>
        </Grid>
      </Container>
    </div>
  )
}

export default App
