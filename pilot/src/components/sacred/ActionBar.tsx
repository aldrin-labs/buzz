import styles from '@components/ActionBar.module.scss';

import * as React from 'react';
import * as Utilities from '@common/utilities';

import ButtonGroup from '@components/ButtonGroup';

interface ActionBarItem {
  hotkey: string;
  onClick?: () => void;
  selected?: boolean;
  body: React.ReactNode;
}

interface ActionBarProps {
  items: ActionBarItem[];
}

const ActionBar: React.FC<ActionBarProps> = ({ items }) => {
  return (
    <div className={styles.root}>
      <ButtonGroup items={items} />
    </div>
  );
};

export default ActionBar;
