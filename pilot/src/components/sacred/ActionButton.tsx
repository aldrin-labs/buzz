import styles from './ActionButton.module.scss';
import * as React from 'react';
import { classNames } from '../../lib/utilities';

interface ActionButtonProps {
  onClick?: () => void;
  hotkey?: string;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

const ActionButton: React.FC<ActionButtonProps> = ({ onClick, hotkey, children, style }) => {
  return (
    <div
      className={classNames(styles.root)}
      onClick={onClick}
      tabIndex={0}
      role="button"
    >
      {!hotkey ? null : <span className={styles.hotkey}>{hotkey}</span>}
      <span className={styles.content} style={style}>
        {children}
      </span>
    </div>
  );
};

export default ActionButton;
