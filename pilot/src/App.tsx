import { ActionBar, Grid, Text, Container } from './components/sacred'
import { CodeBlock } from "./components/CodeBlock"
import { securityExample, aiExample, syntaxExample, solanaExample } from "./lib/code-examples"
import { Link } from 'react-router-dom'

const App: React.FC = () => {
  const actionBarItems = [
    {
      id: 'docs',
      hotkey: 'd',
      body: <Link to="/docs"><Text>DOCS</Text></Link>,
      onClick: () => {}
    },
    {
      id: 'create-dao',
      hotkey: 'c',
      body: <Link to="/create-dao"><Text>CREATE DAO</Text></Link>,
      onClick: () => {}
    }
  ];

  return (
    <div className="app">
      <ActionBar items={actionBarItems}>
        <Text style={{ fontWeight: 500 }}>BUZZ LANG</Text>
      </ActionBar>

      <Container isMain>
        <Grid>
          <div style={{
            maxWidth: '80ch',
            margin: '0 auto',
            textAlign: 'center',
            width: '100%'
          }}>
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

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 450px), 1fr))',
            gap: '3rem',
            width: '100%'
          }}>
            <Text variant="h2" style={{
              color: 'var(--theme-headline)',
              gridColumn: '1 / -1',
              textAlign: 'center',
              marginBottom: '2rem'
            }}>
              Features
            </Text>

            <Container style={{
              height: 'auto',
              width: '100%',
              padding: '2.5rem',
              background: 'var(--theme-gradient-card)',
              borderRadius: '12px',
              display: 'flex',
              flexDirection: 'column',
              gap: '1.5rem'
            }}>
              <Text variant="h3" color="secondary">Security First</Text>
              <Text color="secondary">
                Built-in decorators for ownership verification and reentrancy protection.
              </Text>
              <CodeBlock code={securityExample} language="python" />
            </Container>

            <Container style={{
              height: 'auto',
              width: '100%',
              padding: '2.5rem',
              background: 'var(--theme-gradient-card)',
              borderRadius: '12px',
              display: 'flex',
              flexDirection: 'column',
              gap: '1.5rem'
            }}>
              <Text variant="h3" color="secondary">AI Ready</Text>
              <Text color="secondary">
                First-class support for on-chain AI agents and autonomous programs.
              </Text>
              <CodeBlock code={aiExample} language="python" />
            </Container>

            <Container style={{
              height: 'auto',
              width: '100%',
              padding: '2.5rem',
              background: 'var(--theme-gradient-card)',
              borderRadius: '12px',
              display: 'flex',
              flexDirection: 'column',
              gap: '1.5rem'
            }}>
              <Text variant="h3" color="secondary">Clean Syntax</Text>
              <Text color="secondary">
                Python-like syntax for writing smart contracts.
              </Text>
              <CodeBlock code={syntaxExample} language="python" />
            </Container>

            <Container style={{
              height: 'auto',
              width: '100%',
              padding: '2.5rem',
              background: 'var(--theme-gradient-card)',
              borderRadius: '12px',
              display: 'flex',
              flexDirection: 'column',
              gap: '1.5rem'
            }}>
              <Text variant="h3" color="secondary">Solana Native</Text>
              <Text color="secondary">
                Native Solana integration with built-in account management.
              </Text>
              <CodeBlock code={solanaExample} language="python" />
            </Container>
          </div>
        </Grid>
      </Container>
    </div>
  )
}

export default App
