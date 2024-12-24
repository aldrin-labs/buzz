'use client';

import styles from './page/DefaultActionBar.module.scss';
import * as React from 'react';
import { classNames } from '../../lib/utilities';

import ButtonGroup from './ButtonGroup';
import ActionButton from './ActionButton';

interface ButtonGroupItem {
  hotkey: string;
  onClick: () => void;
  body: React.ReactNode;
}

interface DefaultActionBarProps {
  items?: ButtonGroupItem[];
}

const DefaultActionBar: React.FC<DefaultActionBarProps> = ({ items = [] }) => {
  return (
    <div className={styles.root}>
      <ButtonGroup
        items={[
          {
            hotkey: '⌃+T',
            onClick: () => {
              document.documentElement.classList.toggle('dark');
            },
            body: 'Theme',
          },
          ...items,
        ]}
      />
    </div>
  );
};

export default DefaultActionBar;
