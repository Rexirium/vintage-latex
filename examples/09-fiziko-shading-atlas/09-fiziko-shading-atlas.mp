% SPDX-License-Identifier: CC-BY-SA-4.0
% Requires: https://github.com/jemmybutton/fiziko (GPL-3.0)
% Set MPINPUTS to the directory containing fiziko.mp before running mpost.

prologues := 3;
outputtemplate := "%j-%c.eps";
randomseed := 3141;

input fiziko.mp;

defineMinStrokeWidth(0.2pt);
defineLightDirection(-1/8pi, 1/8pi);

beginfig(1);
  picture a, b, c;
  path spine;

  a := sphere(2.25cm);
  b := sphere.s(2.25cm);
  spine := (0, -1.35cm){dir 80}..(0.2cm, 0)..{dir 100}(0, 1.35cm);
  c := tube.l(spine)(0.58cm * (0.72 + 0.28*cos(offsetPathLength*pi)));

  draw a shifted (-3.0cm, 0);
  draw b;
  draw c shifted (3.0cm, 0);

  label.bot(btex line-shaded sphere etex, (-3.0cm, -1.55cm));
  label.bot(btex stippled sphere etex, (0, -1.55cm));
  label.bot(btex variable tube etex, (3.0cm, -1.55cm));

  draw (-4.45cm, -1.95cm)--(4.45cm, -1.95cm)
    withpen pencircle scaled 0.3pt;

  setbounds currentpicture to
    (-4.85cm, -2.35cm)--(4.85cm, -2.35cm)--
    (4.85cm, 1.65cm)--(-4.85cm, 1.65cm)--cycle;
endfig;

end.
