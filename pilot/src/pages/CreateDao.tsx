import React from 'react'
import { CodeBlock } from '../components/CodeBlock'
import styles from '../App.module.scss'

const daoExample = {
  rust: `#[program]
mod dao {
  use anchor_lang::prelude::*;
  
  #[account]
  pub struct Dao {
    pub authority: Pubkey,
    pub members: Vec<Pubkey>,
    pub proposal_count: u64,
  }

  pub fn create_dao(ctx: Context<CreateDao>) -> Result<()> {
    let dao = &mut ctx.accounts.dao;
    dao.authority = ctx.accounts.authority.key();
    dao.members = vec![ctx.accounts.authority.key()];
    dao.proposal_count = 0;
    Ok(())
  }
}`,
  buzz: `@program_id("DAO1...")
contract Dao:
  authority: PublicKey
  members: List[PublicKey]
  proposal_count: u64

  def create_dao():
    self.authority = ctx.accounts.authority
    self.members = [ctx.accounts.authority]
    self.proposal_count = 0`,
  benchmarks: [
    { metric: "Lines", rust: "      26", buzz: "       9", diff: "  -65%" },
    { metric: "Size (KB)", rust: "    4.2", buzz: "    1.8", diff: "  -57%" },
    { metric: "CU", rust: "   12000", buzz: "   11000", diff: "   -8%" },
    { metric: "Dev Time (h)", rust: "     45", buzz: "     15", diff: "  -67%" },
    { metric: "TTM Coef.", rust: "   13.5", buzz: "    1.5", diff: "  -89%" }
  ]
}

const CreateDao: React.FC = () => {
  return (
    <div className={styles.docLayout}>
      <nav className={styles.navContent}>
        <div className={styles.logo}><span>BUZZ LANG</span></div>
      </nav>

      <div className={styles.docContainer}>
        <aside className={styles.sidebar}>
          <nav className={styles.sideNav}>
            <div className={styles.sideNavSection}>
              <h3 className={styles.sideNavTitle}>DAO Creation</h3>
              <ul>
                <li><a href="#overview" className={styles.active}>Overview</a></li>
                <li><a href="#code">Code Example</a></li>
                <li><a href="#deploy">Deployment</a></li>
              </ul>
            </div>
          </nav>
        </aside>

        <main className={styles.mainContent}>
          <article className={styles.docArticle}>
            <header className={styles.docHeader}>
              <h1 className={styles.heroTitle}>
                <span>Create a DAO in Minutes</span>
              </h1>
              <p className={styles.heroSubtitle}>
                <span>Build and deploy your own DAO on Solana using Buzz's simple syntax and built-in security features.</span>
              </p>
            </header>

            <section id="code" className={styles.docSection}>
              <h2 className={styles.sectionTitle}><span>Code Example</span></h2>
              <p className={styles.sectionText}>
                Create a basic DAO with member management and proposal functionality.
              </p>
              <CodeBlock code={daoExample} />
            </section>
          </article>
        </main>
      </div>
    </div>
  )
}

export default CreateDao
