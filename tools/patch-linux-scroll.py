#!/usr/bin/env python3
"""Map X11 wheel buttons to the app's up/down scroll key events."""
from pathlib import Path
import sys
p = Path(sys.argv[1]) / 'loaders/x11/x11_microgl.c'
s = p.read_text()
if '/* expense tracker wheel scrolling */' not in s:
    start = s.index('case ButtonPress:')
    pos = s.index('          case Button1:', start)
    s = s[:pos] + '''          /* expense tracker wheel scrolling */
          case Button4:
           microgl_hook(EVENT_KEYPRESS, EVENT_KEYUP, 0);
           break;
          case Button5:
           microgl_hook(EVENT_KEYPRESS, EVENT_KEYDOWN, 0);
           break;
''' + s[pos:]
    p.write_text(s)
