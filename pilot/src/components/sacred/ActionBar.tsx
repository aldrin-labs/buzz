import styles from './ActionBar.module.scss';
import * as React from 'react';
import * as Utilities from '../../common/utilities';
import { ButtonGroup, ButtonGroupItem } from './ButtonGroup';

interface ActionBarProps {
  items: ButtonGroupItem[];
  isFull?: boolean;
}

const ActionBar: React.FC<ActionBarProps> = ({ items, isFull }) => {
  return (
    <div className={Utilities.classNames(styles.root)}>
      <ButtonGroup items={items} isFull={isFull} />
    </div>
  );
};

export default ActionBar;
export type { ActionBarProps };
