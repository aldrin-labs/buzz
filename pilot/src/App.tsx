import { DefaultActionBar, Grid, Text, Container } from './components/sacred'
import { CodeBlock } from "./components/CodeBlock"
import { securityExample, cpiExample, agentExample, syntaxExample } from "./lib/code-examples"
import { Link } from 'react-router-dom'
import styles from './App.module.scss'

const App: React.FC = () => {
  return (
    <div className={styles.docLayout}>
      <nav className={styles.navContent}>
        <div className={styles.logo}><span>BUZZ LANG</span></div>
        <div className={styles.navLinks}>
          <Link to="/docs">Documentation</Link>
          <Link to="/create-dao">Create DAO</Link>
        </div>
      </nav>

      <div className={styles.docContainer}>
        <aside className={styles.sidebar}>
          <nav className={styles.sideNav}>
            <div className={styles.sideNavSection}>
              <h3 className={styles.sideNavTitle}>Getting Started</h3>
              <ul>
                <li><a href="#overview" className={styles.active}>Overview</a></li>
                <li><a href="#security">Security First</a></li>
                <li><a href="#cpi">Native CPI Support</a></li>
                <li><a href="#agents">Agent Communication</a></li>
                <li><a href="#syntax">Clean Syntax</a></li>
              </ul>
            </div>
            <div className={styles.sideNavSection}>
              <h3 className={styles.sideNavTitle}>Examples</h3>
              <ul>
                <li><a href="/examples/basic">Basic Usage</a></li>
                <li><a href="/examples/defi">DeFi Examples</a></li>
                <li><a href="/examples/agents">Agent Examples</a></li>
              </ul>
            </div>
            <div className={styles.sideNavSection}>
              <h3 className={styles.sideNavTitle}>Reference</h3>
              <ul>
                <li><a href="/docs/api">API Reference</a></li>
                <li><a href="/docs/security">Security Guide</a></li>
                <li><a href="/docs/deployment">Deployment</a></li>
              </ul>
            </div>
          </nav>
        </aside>

        <main className={styles.mainContent}>
          <article className={styles.docArticle}>
            <header className={styles.docHeader}>
              <h1 className={styles.heroTitle}>
                <span>The Language for Solana Smart Contracts</span>
              </h1>
              <p className={styles.heroSubtitle}>
                <span>Write secure, efficient, and maintainable Solana programs with Python-like syntax.
                Experience the future of smart contract development.</span>
              </p>
            </header>

            <section id="security" className={styles.docSection}>
              <h2 className={styles.sectionTitle}><span>Security First</span></h2>
              <p className={styles.sectionText}>
                Built-in decorators for ownership verification and reentrancy protection.
              </p>
              <CodeBlock code={securityExample} />
            </section>

            <section id="cpi" className={styles.docSection}>
              <h2 className={styles.sectionTitle}><span>Native CPI Support</span></h2>
              <p className={styles.sectionText}>
                Simplified CPI calls with intuitive syntax.
              </p>
              <CodeBlock code={cpiExample} />
            </section>

            <section id="agents" className={styles.docSection}>
              <h2 className={styles.sectionTitle}><span>Agent Communication</span></h2>
              <p className={styles.sectionText}>
                First-class support for on-chain AI agents and autonomous programs.
              </p>
              <CodeBlock code={agentExample} />
            </section>

            <section id="syntax" className={styles.docSection}>
              <h2 className={styles.sectionTitle}><span>Clean Syntax</span></h2>
              <p className={styles.sectionText}>
                Python-like syntax vs Rust/Anchor verbosity.
              </p>
              <CodeBlock code={syntaxExample} />
            </section>
          </article>
        </main>
      </div>
    </div>
  )
}

export default App
