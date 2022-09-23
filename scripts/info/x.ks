RCS OFF.

FUNCTION posAt {
  PARAMETER c, u_time.
  LOCAL b IS ORBITAT(c,u_time):BODY.
  LOCAL p IS POSITIONAT(c, u_time).
  IF b <> BODY { SET p TO p - POSITIONAT(b,u_time). }
  ELSE { SET p TO p - BODY:POSITION. }
  RETURN p.
}

LOCAL t IS TIME:SECONDS.
LOCAL shipToFutureMun IS VECDRAW(SHIP:POSITION,POSITIONAT(MUN,t),BLUE,"future mun is here",1,TRUE,0.2).
LOCAL shipToFutureKerbin IS VECDRAW(SHIP:POSITION,POSITIONAT(KERBIN,t),GREEN,"future kerbin is here",1,TRUE,0.2).
LOCAL shipToFutureShip IS VECDRAW(SHIP:POSITION,POSITIONAT(ship,t),red,"future ship is here",1,TRUE,0.2).
LOCAL m2 IS VECDRAW(SHIP:POSITION,posAt(ship,t),yellow,"ship posAt here",1,TRUE,0.2).

UNTIL RCS {
  WAIT 0.
  SET t TO t + 10.
  SET shipToFutureMun:START TO SHIP:POSITION.
  SET shipToFutureMun:VEC TO POSITIONAT(MUN,t).
  SET shipToFutureKerbin:START TO SHIP:POSITION.
  SET shipToFutureKerbin:VEC TO POSITIONAT(KERBIN,t).
  set shipToFutureShip:START to ship:position.
  set shipToFutureShip:VEC to positionAt(ship, t).
  set m2:start to ship:position.
  set m2:vec to posAt(ship,t).
}
CLEARVECDRAWS().