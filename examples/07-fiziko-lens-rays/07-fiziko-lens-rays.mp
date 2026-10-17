% SPDX-License-Identifier: CC-BY-SA-4.0
% Requires: https://github.com/jemmybutton/fiziko (GPL-3.0)
% Set MPINPUTS to the directory containing fiziko.mp before running mpost.

prologues := 3;
outputtemplate := "%j-%c.eps";
randomseed := 1729;

input fiziko.mp;

defineMinStrokeWidth(0.22pt);
defineLightDirection(-1/8pi, 1/8pi);

beginfig(1);
  path glass, incoming, traced;
  glass := lens((4.5, 4.5), 0.55, 3.2, cm);

  draw (-4.4cm, 0)--(4.7cm, 0)
    dashed evenly scaled 0.65 withpen pencircle scaled 0.28pt;
  draw solid(glass, 52, 1);
  draw glass withpen pencircle scaled 0.58pt;

  for h = -0.95cm step 0.475cm until 0.95cm:
    incoming := (-4.2cm, h)--(-1.0cm, h);
    traced := refractionPath(incoming, glass, 1.52);
    drawmidarrow(traced) withpen pencircle scaled 0.38pt;
  endfor;

  label.top(btex optical axis etex, (3.7cm, 0.12cm));
  label.bot(btex computed ray paths etex, (0, -2.1cm));

  setbounds currentpicture to
    (-4.55cm, -2.45cm)--(4.75cm, -2.45cm)--
    (4.75cm, 1.9cm)--(-4.55cm, 1.9cm)--cycle;
endfig;

end.
