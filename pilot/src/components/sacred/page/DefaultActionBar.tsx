import styles from './DefaultActionBar.module.scss';
import * as React from 'react';
import * as Utilities from '../../../common/utilities';
import { ButtonGroup, ButtonGroupItem } from '../ButtonGroup';

interface DefaultActionBarProps {
  items?: ButtonGroupItem[];
  isFull?: boolean;
}

const DefaultActionBar: React.FC<DefaultActionBarProps> = ({ items = [], isFull }) => {
  return (
    <div className={Utilities.classNames(styles.root)}>
      <ButtonGroup
        items={[
          {
            hotkey: '⌃+T',
            onClick: () => {
              document.documentElement.classList.toggle('dark');
            },
            body: 'Theme'
          },
          ...items,
        ]}
        isFull={isFull}
      />
    </div>
  );
};

export default DefaultActionBar;
export type { DefaultActionBarProps };
