'use client';

import styles from './ButtonGroup.module.scss';
import * as React from 'react';
import { classNames } from '../../lib/utilities';
import { ActionButton } from './ActionButton';

interface ButtonGroupItem {
  hotkey: string;
  onClick: () => void;
  body: React.ReactNode;
}

interface ButtonGroupProps {
  items?: ButtonGroupItem[];
  isFull?: boolean;
}

const ButtonGroup: React.FC<ButtonGroupProps> = (props) => {
  if (!props.items) {
    return null;
  }

  return (
    <div className={classNames(styles.root, props.isFull ? styles.full : null)}>
      {props.items.map((each) => {
        return (
          <ActionButton
            key={each.body?.toString()}
            onClick={each.onClick}
            hotkey={each.hotkey}
          >
            {each.body}
          </ActionButton>
        );
      })}
    </div>
  );
};

export default ButtonGroup;
