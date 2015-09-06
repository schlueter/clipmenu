#!/usr/bin/env python

from __future__ import print_function

import os
import subprocess
import errno
import time
import sys
from nose.tools import assert_equal

SCRIPT_DIR = os.path.dirname(__file__)
sys.path.append(SCRIPT_DIR)
print(sys.path, file=sys.stderr)
from fake_scripts import xsel


FAKE_SCRIPTS_DIR = os.path.join(SCRIPT_DIR, 'fake_scripts')
POLL_FREQ = 0.1
DMENU_STDIN_PATH = '/tmp/_dmenu_test_stdin'


def setup():
    # Prepend fake scripts dir to PATH so that the scripts get picked up by
    # clipmenu/clipmenud, and ".." to pick up clipmenu/clipmenud
    os.environ['PATH'] = ':'.join([FAKE_SCRIPT_DIR, '..', os.environ['PATH']])

    # Wipe out any old fake clipboard data that might infect our test
    # environment
    try:
        os.unlink(xsel.FAKE_CLIPBOARD)
    except OSError as thrown_exc:
        if thrown_exc.errno != errno.ENOENT:
            raise


def run_clipmenud():
    env = os.environ.copy()
    env['CLIPMENUD_SLEEP'] = POLL_FREQ
    proc = subprocess.Popen(['clipmenud'], env=env)
    pid = proc.pid
    return pid


def run_clipmenu():
    subprocess.check_call(['clipmenu'])

    with open(DMENU_STDIN_PATH, 'r') as dmenu_stdin_f:
        dmenu_stdin = dmenu_stdin_f.read()

    return {
        'dmenu_stdin': dmenu_stdin,
    }


def test_clipmenud_basic_read():
    clipmenud_pid = run_clipmenud()
    xsel.write_to_fake_clipboard('foo\nbar\n')
    time.sleep(1)
    clipmenu = run_clipmenu()
    os.kill(clipmenud_pid)
    assert_equal(clipmenu['dmenu_stdin'], 'foo (2 lines)\n')
