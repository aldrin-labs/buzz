import * as React from 'react';
import styles from './Navigation.module.scss';
import { Text, Container } from './index';

interface NavigationProps extends React.HTMLAttributes<HTMLElement> {
  children?: React.ReactNode;
  className?: string;
}

export const Navigation: React.FC<NavigationProps> = ({
  children,
  className,
  ...rest
}) => {
  return (
    <nav className={`${styles.navigation} ${className || ''}`} {...rest}>
      <Container>
        <div className={styles.content}>
          <section>
            <Text variant="h3" className={styles.brand}>
              <a href="/">Buzz Lang</a>
            </Text>
          </section>
          <section>
            <Text variant="p" className={styles.link}>Theme</Text>
            <Text variant="p" className={styles.link}><a href="/docs">Docs</a></Text>
            <Text variant="p" className={styles.link}><a href="/examples">Examples</a></Text>
            <Text variant="p" className={styles.link}><a href="/api">API</a></Text>
          </section>
        </div>
      </Container>
    </nav>
  );
};

export default Navigation;
