import * as React from 'react'
import styles from './Navigation.module.scss'

interface NavigationProps extends React.HTMLAttributes<HTMLElement> {
  children?: React.ReactNode
  className?: string
}

const Navigation: React.FC<NavigationProps> = ({
  children,
  className,
  ...rest
}) => {
  return (
    <nav
      className={`${styles.navigation} ${className || ''}`}
      {...rest}
    >
      {children}
    </nav>
  )
}

export default Navigation
