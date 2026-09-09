% SPDX-License-Identifier: CC-BY-SA-4.0
% Requires: https://github.com/jemmybutton/fiziko (GPL-3.0)
% Set MPINPUTS to the directory containing fiziko.mp before running mpost.

prologues := 3;
outputtemplate := "%j-%c.eps";
randomseed := 2718;

input fiziko.mp;

defineMinStrokeWidth(0.22pt);
defineLightDirection(-1/8pi, 1/8pi);

% Build one canonical fiziko weight and reuse scaled instances. This keeps the
% two loads visually identical apart from their scale.
picture standardWeight;
standardWeight := weight.h(1cm);

beginfig(1);
  numeric pulleyDiameter, pulleyRadius;
  pair pulleyCenter, leftload, rightload;
  path ceiling, ropePath;

  pulleyDiameter := 1.65cm;
  pulleyRadius := pulleyDiameter/2;
  pulleyCenter := (0, -1.25cm);
  leftload := (-pulleyRadius, -5.0cm);
  rightload := (pulleyRadius, -4.1cm);

  ceiling := (2.3cm, 0)--(-2.3cm, 0);
  draw solidSurface(ceiling);

  ropePath := leftload--(-pulleyRadius, ypart(pulleyCenter))
          ..controls (-pulleyRadius, ypart(pulleyCenter)+0.47pulleyRadius)
             and (-0.47pulleyRadius, ypart(pulleyCenter)+pulleyRadius)..
          (0, ypart(pulleyCenter)+pulleyRadius)
          ..controls (0.47pulleyRadius, ypart(pulleyCenter)+pulleyRadius)
             and (pulleyRadius, ypart(pulleyCenter)+0.47pulleyRadius)..
          (pulleyRadius, ypart(pulleyCenter))--rightload;
  draw ropePath withpen pencircle scaled 0.48pt;

  draw standardWeight scaled 1.15 shifted leftload;
  draw standardWeight scaled 0.82 shifted rightload;
  draw pulley(pulleyDiameter, 0) shifted pulleyCenter;
  label.lft(btex $m_1$ etex, leftload shifted (-0.15cm, -0.55cm));
  label.rt(btex $m_2$ etex, rightload shifted (0.15cm, -0.42cm));

  drawarrow (1.75cm, -5.20cm)--(1.75cm, -4.35cm)
    withpen pencircle scaled 0.42pt;
  label.rt(btex acceleration etex, (1.82cm, -4.78cm));

  setbounds currentpicture to
    (-2.65cm, -6.45cm)--(4.15cm, -6.45cm)--
    (4.15cm, 0.35cm)--(-2.65cm, 0.35cm)--cycle;
endfig;

end.
