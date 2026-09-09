% SPDX-License-Identifier: CC-BY-SA-4.0
% Requires: https://github.com/jemmybutton/fiziko (GPL-3.0)
%
% Set MPINPUTS to the directory containing fiziko.mp before running mpost.

prologues := 3;
outputtemplate := "%j-%c.eps";
randomseed := 1729;

input fiziko.mp;

defineMinStrokeWidth(0.35pt);
defineLightDirection(-1/8pi, 1/8pi);

beginfig(1);
  pair fixedPoint, weightTop, datumTop, datumBottom;
  fixedPoint := (0, 0);
  weightTop := (0, -4.4cm);
  datumTop := (2.2cm, -1.2cm);
  datumBottom := (2.2cm, ypart weightTop);

  % Reverse the support path so fiziko hatches the material above the line.
  draw solidSurface((1.7cm, 0) -- (-1.7cm, 0));

  % These two modeled objects are the fiziko-specific core of the example.
  draw spring(fixedPoint, weightTop, 18);
  draw weight.h(1.45cm) shifted weightTop;

  % Plain MetaPost remains useful for precise annotations around the model.
  draw (0.75cm, ypart weightTop) -- (2.45cm, ypart weightTop)
       dashed evenly withpen pencircle scaled 0.35pt;
  draw (1.85cm, ypart datumTop) -- (2.45cm, ypart datumTop)
       withpen pencircle scaled 0.35pt;
  drawdblarrow datumTop -- datumBottom
       withpen pencircle scaled 0.42pt;

  label.rt(btex $x$ etex, 1/2[datumTop, datumBottom] shifted (2mm, 0));
  label.lft(btex $k$ etex, (-2mm, -2.25cm));

  drawarrow (1.0cm, -5.05cm) -- (1.0cm, -6.05cm)
       withpen pencircle scaled 0.42pt;
  label.rt(btex $W$ etex, (1.15cm, -5.55cm));

  label.bot(
    btex \font\it=cmti10 at 11pt \it Elastic extension of a hanging load etex,
    (0.4cm, -6.7cm)
  );

  bboxmargin := 12bp;
  setbounds currentpicture to bbox currentpicture;
endfig;

end
