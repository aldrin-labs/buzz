'use client';

import styles from './ModalError.module.scss';

import * as React from 'react';
import * as Utilities from '../../../common/utilities';

import { useHotkeys } from '../../../modules/hotkeys';
import { useModals } from '../../../context/ModalContext';

import ActionButton from '../ActionButton';
import Button from '../Button';
import CardDouble from '../CardDouble';
import Grid from '../Grid';

interface ModalErrorProps {
  buttonText?: string | any;
  message: string | any;
  title?: string;
}

function ModalError({ message, buttonText, title }: ModalErrorProps) {
  const { close } = useModals();

  useHotkeys('enter', () => close());

  return (
    <div className={styles.root}>
      <CardDouble title={title}>
        <br />
        {message}
        <Grid>
          <ul>
            <li>
              Press{' '}
              <ActionButton hotkey="⏎" onClick={() => close()}>
                {' '}
                ENTER
              </ActionButton>{' '}
              to continue.
            </li>
          </ul>
        </Grid>
      </CardDouble>
    </div>
  );
}

export default ModalError;
