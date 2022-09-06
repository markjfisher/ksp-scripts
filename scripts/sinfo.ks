// Works, but is sooooooooooooo long. needs distilling down to just VdV or rewriting.
@lazyglobal off.
function stinfo {
  parameter atmo IS "current".
  local sub to list().
  local stZ to list().
  from {local s IS 0.} until s > STAGE:NUMBER step {set s to s+1.} do {
    stZ:ADD(0).
    sub:ADD(list()).
  }
  local stmass to stZ:COPY.
  local sticon to stZ:COPY.
  local stithruV to stZ:COPY.
  local stithruA to stZ:COPY.
  local stburn to stZ:COPY.
  local stfuel to stZ:COPY.
  local stleft to stZ:COPY.
  local sinfolist to stZ:COPY.
  local ox2lf to 9.0/11.0.
  local procli to list().
  local egli to list().
  local egtali to list().
  local egfdli to list().
  local egastage to 999.
  local egdstage to 999.
  local fdtotal to 0.
  local actfdstart to list().
  local actfdend to list().

  local fairingmass to LEXICON(
    "fairingSize1", 0.075,
      "fairingSize1p5", 0.15,
      "fairingSize2", 0.175,
      "fairingSize3", 0.475,
      "fairingSize4", 0.8
    ).

  local nocflist to LIST("smallHardpoint",
    "structuralIBeam1", "structuralIBeam2", "structuralIBeam3",
    "structuralPylon",
    "structuralPanel1", "structuralPanel2",
    "InflatableHeatShield",
    "HeatShield0", "HeatShield1", "HeatShield2", "HeatShield3",
    "noseCone", "rocketNoseCone", "rocketNoseCone_v2", "rocketNoseConeSize3",
    "strutConnector",
    "Panel0", "Panel1", "Panel1p5", "Panel2",
    "EquiTriangle0", "EquiTriangle1", "EquiTriangle1p5", "EquiTriangle2",
    "Size_1_5_Cone", "rocketNoseConeSize4",
    "Triangle0", "Triangle1", "Triangle1p5", "Triangle2",
    "HeatShield1p5" ).

  local fuli to LIST("LiquidFuel", "Oxidizer", "SolidFuel", "XenonGas").
  local LFidx to fuli:FIND("LiquidFuel").
  local OXidx to fuli:FIND("Oxidizer").
  local SOidx to fuli:FIND("SolidFuel").
  local XEidx to fuli:FIND("XenonGas").
  local fuCorr to LIST(1, 1, 1, 1).
  set fuCorr[OXidx] to 20/11.
  local fuliZ to LIST(0,0,0,0).
  local fuMin to 1e-6.
  local con to list().
  local thruV to list().
  local thruA to list().
  local conW to list().
  local conP to list().
  local thruVW to list().
  local thruAW to list().
  local cfma to list().
  local fdfma to list().
  local fdnum to list().
  local burnsrc to list().
  local burnsrcLF to list().
  local burndu to list().
  local donebu to list().

  local elist to -999. list engines IN elist.
  local fdlist to SHIP:PARTSNAMED("fuelLine").
  for p IN fdlist {
    elist:ADD(p).
  }

  local egidx to 0.
  local eg to list().
  for e IN elist {
    set egastage to e:STAGE.
    set egdstage to e:DECOUPLEDIN.
    set egli to list().
    set egtali to list().
    set egfdli to list().
    if eTree(e,0) {
      eg:ADD(0).
      set eg[egidx] to LEXICON().
      set eg[egidx]["egli"] to egli.
      set eg[egidx]["egtali"] to egtali.
      set eg[egidx]["egfdli"] to egfdli.
      set eg[egidx]["egastage"] to egastage.
      set eg[egidx]["egdstage"] to egdstage.
      set eg[egidx]["egfddest"] to list().
      set eg[egidx]["egfdsrc"] to list().
      set eg[egidx]["actfddest"] to list().
      set eg[egidx]["actfdsrc"] to list().
      set egidx to egidx+1.
    }
  }

  local plist to -999. LIST PARTS IN plist.
  for p IN plist {
    local ineg to 1.
    if NOT procli:CONTAINS(p:UID) {
      set ineg to 0.
    }
    local lst is p:DECOUPLEDIN+1.
    local ast is p:STAGE.
    local kst is lst.
    local pmass IS p:DRYMASS.

    if p:TYPENAME = "LaunchClamp" { set pmass to 0. }
    if p:TYPENAME = "Decoupler" {
      set kst to ast+1.
    }

    if fairingmass:HASKEY(p:NAME) {
      local fpanel IS p:MASS - fairingmass[p:NAME].
      if ast < STAGE:NUMBER {
        set stmass[ast+1] to stmass[ast+1] + fpanel.
        set pmass to pmass - fpanel.
      }
    }

    if p:MASS > p:DRYMASS {
      for r IN p:RESOURCES {
        if NOT fuli:CONTAINS(r:NAME) OR NOT procli:CONTAINS(p:UID){
          set pmass to pmass + r:DENSITY*r:AMOUNT.
        }
      }
    }
    set stmass[kst] to stmass[kst] + pmass.
  }

  from {local i is 0.} until i > eg:LENGTH-1 step {set i to i+1.} do {
    con:ADD(stZ:COPY).
    thruV:ADD(stZ:COPY).
    thruA:ADD(stZ:COPY).
    from {local s IS 0.} until s > STAGE:NUMBER step {set s to s+1.} do {
      set con[i][s] to fuliZ:COPY.
      set thruV[i][s] to fuliZ:COPY.
      set thruA[i][s] to fuliZ:COPY.
    }

    conW:ADD(fuliZ:COPY).
    conP:ADD(fuliZ:COPY).
    thruVW:ADD(fuliZ:COPY).
    thruAW:ADD(fuliZ:COPY).
    cfma:ADD(fuliZ:COPY).
    fdfma:ADD(fuliZ:COPY).
    fdnum:ADD(fuliZ:COPY).
    burnsrc:ADD(fuliZ:COPY).
    burnsrcLF:ADD(fuliZ:COPY).
    burndu:ADD(fuliZ:COPY).
    donebu:ADD(fuliZ:COPY).

    if eg[i]:egfdli:LENGTH > 1 {
      print " ".
      print "The sinfo library supports only one fuel duct going out of a engine group!".
      print " ".
      print 1/0.
    }

    for fl IN eg[i]:egfdli {
      local fulinetarget to False.
      local kTag to fl:GETMODULE("KOSNameTag"):GETFIELD("name tag").
      if kTag = "" {
        set kTag to "<none>".
      } else {
        if kTag = "<none>" {
          print "Fuel Ducts cannot have a kOS tag with the value <none>.".
          print "That tag value us used for internal fuel duct processing,".
          print "Please use a different tag to identify fuel duct targets.".
          print " ".
          return 0.
        }

        local alltags to SHIP:PARTSTAGGED(kTag).
        local alltags2 to list().
        for p IN alltags {
          if p:NAME <> "fuelLine" {
            alltags2:ADD(p).
          }
        }
        if alltags2:LENGTH <> 1 {
          print "There needs to be exactly one target part with the same".
          print "kOS name tag as the fuel duct!".
          print "Found: "+alltags2:LENGTH+" targets with kOS tag: "+ktag.
          print "The tag will be ignored and the decoupler logic be used.".
          print " ".
          set kTag to "<none>".
        } else {
          set fulinetarget to alltags2[0].
        }
      }
      if kTag = "<none>" {
        local pa to fl:DECOUPLER:PARENT.
        local ch to fl:DECOUPLER:CHILDREN[0].
        set fulinetarget to pa.
        if eg[i]:egli:CONTAINS(pa) {
          set fulinetarget to ch.
        }
      }

      local fddesteg to -1.
      from {local x IS 0.} until x >= eg:LENGTH step {set x to x+1.} do {
        if eg[x]:egli:CONTAINS(fulinetarget) {
          set fddesteg to x.
          break.
        }
      }

      if fddesteg <> i {
        eg[i]:egfddest:ADD(fddesteg).
        eg[fddesteg]:egfdsrc:ADD(i).
        set fdtotal to fdtotal + 1.
      }

    }
  }
  from {local i is 0.} until i > eg:LENGTH-1 step {set i to i+1.} do {
    for x in eg[i]:egtali {
      if x:TYPENAME = "Engine" {
        setConThru(x, i).
      }

      if x:MASS > x:DRYMASS {
        for r IN x:RESOURCES {
          local fti to fuli:FIND(r:NAME).
          if fti >= 0 {
            set cfma[i][fti] to cfma[i][fti] + r:AMOUNT*r:DENSITY.
          }
        }
      }
    }
  }

  from {local s IS STAGE:NUMBER.} until s < 0 step {set s to s-1.} do {
    local btstage to 0.
    set conW to list().
    set conP to list().
    set actfdstart to list().
    set actfdend to list().
    from {local e is 0.} until e > eg:LENGTH-1 step {set e to e+1.} do {
      conW:ADD(fuliZ:COPY).
      conP:ADD(fuliZ:COPY).
      set eg[e]:actfdsrc to list().
      set eg[e]:actfddest to list().

      if s > eg[e]:egdstage {
        for ee IN eg[e]:egfdsrc {
          if s > eg[ee]:egdstage {
            eg[e]:actfdsrc:ADD(ee).
          }
        }
        for ee IN eg[e]:egfddest {
          if s > eg[ee]:egdstage {
            eg[e]:actfddest:ADD(ee).
          }
        }
        if eg[e]:actfddest:LENGTH = 0 {
          if eg[e]:actfdsrc:LENGTH > 0 {
            actfdend:ADD(e).
          } else if s <= eg[e]:egastage AND s > eg[e]:egdstage {
            actfdend:ADD(e).
            actfdstart:ADD(e).
          }
        }

        if eg[e]:actfdsrc:LENGTH = 0 AND eg[e]:actfddest:LENGTH > 0 {
          actfdstart:ADD(e).
        }

      }
    }

    for i IN actfdend {
      setFDfma(i).
      setConThruFD(i,s).
    }

    local dsloop to 0.
    local dostage to False.
    local hasdropeg to False.
    local nofuel to True.
    local fuleft to 0.
    local acteg to 0.
    local dropeg to "".
    from {local e is 0.} until e > eg:LENGTH-1 step {set e to e+1.} do {
      if s <= eg[e]:egastage { set acteg to acteg+1. }
      if s = eg[e]:egdstage+1 {
        set hasdropeg to True.
        set dropeg to dropeg+" "+e.
        local tfuel to 0.

        from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
          if conP[e][f] > 0 {
            set tfuel to tfuel + cfma[e][f].
            if f = OXidx { set tfuel to tfuel + cfma[e][LFidx]. }
          }
          set fuleft to fuleft + cfma[e][f].
        }
        if tfuel > 1e-7 {
          set nofuel to False.
        }
      }
    }

    if acteg < 1 {
      set dostage to True.
    } else if nofuel AND hasdropeg {
      set dostage to True.
      set stleft[s] to fuleft.
    }

    until dostage = True {
      set dsloop to dsloop + 1.
      from {local e is 0.} until e > eg:LENGTH-1 step {set e to e+1.} do {
        set burndu[e] to fuliZ:COPY.
        set donebu[e] to fuliZ:COPY.
      }

      local minburn to 1e12.
      for e IN actfdstart {
        local bustr to "".
        local bsrcstr to "".
        from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
          local burnV to choose 0 if conW[e][f] = 0 else cfma[e][f] / conW[e][f].
          if f = OXidx {
            local burnLF to choose 0 if conW[e][f] = 0 else cfma[e][LFidx] / (conW[e][f]*ox2lf).
            set burnV to MIN(burnV,burnLF).
            set burnsrcLF[e][OXidx] to e.
            set burnsrcLF[e][LFidx] to e.
          }
          set burndu[e][f] to burnV.
          set burnsrc[e][f] to e.
          local edstr to "".
          local ee to e.
          if burnV < 0.01 {
            local stoploop to False.
            local ed to -1.
            until stoploop = True {
              if eg[ee]:actfddest:LENGTH > 0 {
                set ed to eg[ee]:actfddest[0].
                set edstr to edstr+"->"+ed.
                if fdnum[ed][f] > 0 {
                  set burnsrc[e][f] to -1.
                  break.
                }
                if donebu[ed][f] {
                  set burnsrc[e][f] to -1.
                  break.
                }

                if conW[ed][f] > 0 {
                  if f = OXidx {
                    if  fdfma[ed][f] > 0 AND fdfma[ed][LFidx] > 0 {
                      local LFsrc to ed.
                      local OXsrc to ed.
                      if fdfma[ed][f] > cfma[ed][f] OR fdfma[ed][LFidx] > cfma[ed][LFidx] {
                        local rval to getREsrc(ed).
                        set LFsrc to rval[0].
                        set OXsrc to rval[1].
                      }
                      local burnOX to cfma[OXsrc][OXidx] / conW[ed][OXidx].
                      local burnLF to cfma[LFsrc][LFidx] / (conW[ed][OXidx]*ox2lf).
                      set stoploop to True.
                      set burndu[e][f] to MIN(burnOX,burnLF).
                      set burnsrc[e][f] to ed.
                      set burnsrcLF[e][OXidx] to OXsrc.
                      set burnsrcLF[e][LFidx] to LFsrc.
                      set donebu[ed][f] to 1.
                      if burndu[e][f] = 0 {
                        print "cannot handle case.".
                        print 1/0.
                      }
                    }
                  } else {
                    set burnV to choose 0 if conW[ed][f] = 0 else cfma[ed][f] / conW[ed][f].
                    if burnV > 0 {
                      set stoploop to True.
                      set burndu[e][f] to burnV.
                      set burnsrc[e][f] to ed.
                      set burnsrcLF[e][OXidx] to -1.
                      set burnsrcLF[e][LFidx] to -1.
                      set donebu[ed][f] to 1.
                    }
                  }
                }
                set ee to ed.
              } else {
                set stoploop to True.
                set burnsrc[e][f] to -1.
              }
            }
          } else {
            set donebu[e][f] to 1.
          }
        }

        if conW[e][LFidx] > 0 AND conW[e][OXidx] > 0 {
          local LFXcon to conW[e][LFidx] + conW[e][OXidx]*ox2lf.

          local LFXburn to choose 0 if LFXcon = 0 else cfma[e][LFidx]/LFXcon.
          local OXburn to burndu[e][OXidx].
          local LFburn to burndu[e][LFidx].
          if LFXburn < OXburn {

            set OXburn to LFXburn.
            set burndu[e][OXidx] to OXburn.
          }

          set LFburn to choose 0 if conW[e][LFidx] = 0 ELSE
            (cfma[e][LFidx] - OXburn*conW[e][OXidx]*ox2lf) / conW[e][LFidx].
          set burndu[e][LFidx] to LFburn.
        }
      }

      for e IN actfdstart {

        from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
          if burndu[e][f] > 0 AND burndu[e][f] < minburn { set minburn to burndu[e][f]. }
        }
      }

      from {local e is 0.} until e > eg:LENGTH-1 step {set e to e+1.} do {

        if cfma[e][SOidx] > 0 AND NOT(actfdstart:CONTAINS(e)) AND s <= eg[e]:egastage
          AND s > eg[e]:egdstage AND  conW[e][SOidx] > 0 {

          local burnV to cfma[e][SOidx] / conW[e][SOidx].
          if burnV < minburn { set minburn to burnV. }
        }
      }

      set minburn to choose 0 if minburn = 1e12 else minburn.
      set btstage to btstage+minburn.

      if minburn = 0 {
        set dostage to True.
      } else {

        local fuma to 0.
        local conS to 0.
        local thruVS to 0.
        local thruAS to 0.

        sub[s]:ADD(LEXICON("bt", minburn, "con", 0, "thruV", 0, "thruA", 0)).

        for e IN actfdstart {
          from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
            if f <> SOidx AND burndu[e][f] > 0 {
              local fucon to 0.
              local fuconLF to 0.

              local bs to burnsrc[e][f].

              set fucon to conW[bs][f]*minburn.
              set conS to conS + conW[bs][f].
              set thruVS to thruVS + thruVW[bs][f].
              set thruAS to thruAS + thruAW[bs][f].

              if f = OXidx AND conW[bs][f] > 0 {
                local bsLF to burnsrcLF[e][LFidx].
                set fuconLF to conW[bs][f]*ox2lf*minburn.
                set conS to conS + conW[bs][f]*ox2lf.
                set cfma[bsLF][LFidx] to cfma[bsLF][LFidx] - fuconLF.
                if ABS(cfma[bsLF][LFidx]) < fuMin {
                  set cfma[bsLF][LFidx] to 0.
                }
                set fuma to fuma + fuconLF.

                set bs to burnsrcLF[e][OXidx].
              }
              set cfma[bs][f] to cfma[bs][f] - fucon.
              if ABS(cfma[bs][f]) < fuMin {
                set cfma[bs][f] to 0.
              }
              if cfma[bs][f] < 0 {
                print "Error. Fuel: "+ROUND(cfma[bs][f],4)+" in eg,bs,ft: "+e+","+bs+","+f.
                print 1/0.
              }
              set fuma to fuma + fucon.
            }
          }
        }

        from {local e is 0.} until e > eg:LENGTH-1 step {set e to e+1.} do {

          if cfma[e][SOidx] > 0 AND s <= eg[e]:egastage AND s > eg[e]:egdstage  {
            local fucon to conW[e][SOidx]*minburn.
            set conS to conS + conW[e][SOidx].
            set thruVS to thruVS + thruVW[e][SOidx].
            set thruAS to thruAS + thruAW[e][SOidx].
            if fucon > cfma[e][SOidx] {
              print "Missed a shorter SRB minimum burn! Abort!".
              print 1/0.
            }

            set cfma[e][SOidx] to cfma[e][SOidx] - fucon.
            set fuma to fuma + fucon.
            if ABS(cfma[e][SOidx]) < fuMin {
              set cfma[e][SOidx] to 0.
            }
          }
        }

        set stfuel[s] to stfuel[s] + fuma.
        local sidx to sub[s]:LENGTH-1.
        set sub[s][sidx]:con to conS.
        set sub[s][sidx]:thruV to thruVS.
        set sub[s][sidx]:thruA to thruAS.
      }

      local nofuel to True.
      local hasdropeg to False.
      local fuleft to 0.
      from {local e is 0.} until e > eg:LENGTH-1 step {set e to e+1.} do {

        if s = eg[e]:egdstage+1 {

          set hasdropeg to True.
          set dropeg to dropeg+" "+e.

          local tfuel to 0.

          from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
            if conP[e][f] > 0 {
              set tfuel to tfuel + cfma[e][f].

              if f = OXidx AND conP[e][LFidx] = 0 { set tfuel to tfuel + cfma[e][LFidx]. }
            }

            set fuleft to fuleft + cfma[e][f].
          }
          if tfuel > 1e-7 {
            set nofuel to False.

          }
        }
      }
      if nofuel AND hasdropeg { set dostage to True. }

      if dostage {
        set stburn[s] to btstage.
        set stleft[s] to fuleft.
      } else {

        for e IN actfdend {

          setFDfma(e).

          setConThruFD(e,s).
        }
        egCoFuLog(s).
      }
    }
  }

  function getREsrc {
    parameter e.

    local LFre to choose e if cfma[e][LFidx] > 0 else -1.
    local OXre to choose e if cfma[e][OXidx] > 0 else -1.

    for es IN eg[e]:actfdsrc {

      local rval to getREsrc(es).
      if rval[0] >= 0 AND cfma[rval[0]][LFidx] > fuMin {
        set LFre to rval[0].

      }
      if rval[1] >= 0 AND cfma[rval[1]][OXidx] > fuMin {
        set OXre to rval[1].

      }
    }
    return LIST(LFre,OXre).
  }

  function setFDfma {
    parameter e.

    from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
      set fdfma[e][f] to cfma[e][f].
    }
    for es IN eg[e]:actfdsrc {
      setFDfma(es).
      from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {

        if f <> SOidx {
          set fdfma[e][f] to fdfma[e][f] + fdfma[es][f].
        }
      }
    }
    return 1.
  }

  function setConThruFD {
    parameter e,
      s.

    from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
      set conP[e][f] to con[e][s][f].

      if fdfma[e][f] > 0 AND ( f <> OXidx OR fdfma[e][LFidx] > 0 ) {

        set conW[e][f] to con[e][s][f].
        set thruVW[e][f] to thruV[e][s][f].
        set thruAW[e][f] to thruA[e][s][f].
      } else {
        set conW[e][f] to 0.
        set thruVW[e][f] to 0.
        set thruAW[e][f] to 0.
      }
    }

    set fdnum[e] to fuliZ:COPY.
    for es IN eg[e]:actfdsrc {
      from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {
        if fdfma[es][f] > 0 {
          if f = OXidx AND fdfma[es][LFidx] = 0 {

          } else {
            set fdnum[e][f] to fdnum[e][f]+1.
          }
        }
      }
    }

    for ed IN eg[e]:actfddest {
      from {local f is 0.} until f > fuli:LENGTH-1 step {set f to f+1.} do {

        if f <> SOidx AND fdnum[ed][f] > 0 AND fdfma[e][f] > 0 {
          if f <> OXidx OR fdfma[e][LFidx] > 0 {

            set conW[e][f] to conW[e][f] + conW[ed][f] / fdnum[ed][f].
            set thruVW[e][f] to thruVW[e][f] + thruVW[ed][f] / fdnum[ed][f].
            set thruAW[e][f] to thruAW[e][f] + thruAW[ed][f] / fdnum[ed][f].
          }
        }

        set conP[e][f] to conP[e][f] + conP[ed][f].
      }
    }

    for ee IN eg[e]:actfdsrc {
      setConThruFD(ee,s).
    }

    return 1.
  }

  local startmass IS 0.
  local endmass IS 0.

  local sinfo IS LEXICON().

  from {local s is 0.} until s > STAGE:NUMBER step {set s to s+1.} do {
    local prevstartmass IS startmass.
    local fuleft to stleft[s].
    local fuburn to stfuel[s].
    set endmass to startmass + stmass[s] + fuleft.
    set startmass to startmass + stmass[s] + fuburn + fuleft.
    local stagedmass to choose endmass - prevstartmass if s>0 else 0.

    local stfubu to 0.
    local stVdV to 0.
    local stAdV to 0.
    local curmass to startmass.

    local sTWR to 0.
    local sSLT to 0.
    if sub[s]:LENGTH > 0 {
      set sTWR to sub[s][0]:thruV/startmass/CONSTANT:g0.
      set sSLT to sub[s][0]:thruA/startmass/CONSTANT:g0.
    }
    local maxTWR to 0.
    local maxSLT to 0.

    from {local i is 0.} until i > sub[s]:LENGTH-1 step {set i to i+1.} do {
      local fcon to sub[s][i]:con.
      local fthruV to sub[s][i]:thruV.
      local fthruA to sub[s][i]:thruA.
      local ispsV to fthruV/fcon/CONSTANT:g0.
      local ispsC to fthruA/fcon/CONSTANT:g0.
      local subfubu to fcon*sub[s][i]:bt.
      set stfubu to stfubu + subfubu.
      local submass to curmass - subfubu.
      set maxTWR to MAX(maxTWR, sub[s][i]:thruV/submass/CONSTANT:g0).
      set maxSLT to MAX(maxSLT, sub[s][i]:thruA/submass/CONSTANT:g0).
      local subVdV to ispsV*CONSTANT:g0*LN(curmass/submass).
      local subAdV to ispsC*CONSTANT:g0*LN(curmass/submass).
      set stVdV to stVdV + subVdV.
      set stAdV to stAdV + subAdV.
      set curmass to submass.
    }
    local KERispV to 0.
    local KERispA to 0.
    if stVdV {
      set KERispV to stVdV/CONSTANT:g0/LN(startmass/endmass).
      set KERispA to stAdV/CONSTANT:g0/LN(startmass/endmass).
    }

    local KSPispV IS 0.
    local KSPispA IS 0.
    local thruV IS stithruV[s].
    local thruA IS stithruA[s].
    if fuburn = 0 {
      set thruV to 0.
      set thruA to 0.
    }

    if sticon[s] > 0 {
      set KSPispV to thruV/sticon[s]/CONSTANT:g0.
      set KSPispA to thruA/sticon[s]/CONSTANT:g0.
    }

    set sinfo["SMass"] to startmass.
    set sinfo["EMass"] to endmass.
    set sinfo["DMass"] to stagedmass.
    set sinfo["BMass"] to fuburn.
    set sinfo["sTWR"] to sTWR.
    set sinfo["maxTWR"] to maxTWR.
    set sinfo["sSLT"] to sSLT.
    set sinfo["maxSLT"] to maxSLT.
    set sinfo["FtV"] to thruV.
    set sinfo["FtA"] to thruA.
    set sinfo["KSPispV"] to KSPispV.
    set sinfo["KERispV"] to KERispV.
    set sinfo["KSPispA"] to KSPispA.
    set sinfo["KERispA"] to KERispA.
    set sinfo["VdV"] to stVdV.
    set sinfo["AdV"] to stAdV.
    set sinfo["dur"] to stburn[s].
    set sinfo["ATMO"] to atmo.
    set sinfolist[s] to sinfo:COPY.
  }

  return sinfolist.

  function eTree {
    parameter p, l.
    if procli:CONTAINS(p:UID) {
      return False.
    }

    local xfeed to True.
    local thisEg to True.
    local stopWalk to False.
    if p:MASS > p:DRYMASS or p:TYPENAME = "Engine" {
      egtali:ADD(p).
      if p:TYPENAME = "Engine" {
        local pastage to p:STAGE.
        local pdstage to p:DECOUPLEDIN.
        if pastage > egastage { set egastage to pastage. }
        if pdstage > egdstage { set egdstage to pdstage. }
      }
    }

    if p:NAME = "fuelLine" {
      egfdli:ADD(p).
    }.

    if p:HASMODULE("ModuleToggleCrossfeed") {
      if p:GETMODULE("ModuleToggleCrossfeed"):HASEVENT("enable crossfeed") {
        set xfeed to False.
      }
    }

    if p:TYPENAME = "Decoupler" {
      if xfeed {
      } else {
        local pa to p:PARENT.
        local ch to p:CHILDREN[0].
        local procfrom to ch.
        if egli:CONTAINS(pa) {
          set procfrom to pa.
        }

        if procfrom:DECOUPLEDIN < p:STAGE {
          procli:ADD(p:UID).
          egli:ADD(p).
        } else {
          set thisEg to False.
        }
        set stopWalk to True.
      }
    }

    if thisEg {
      procli:ADD(p:UID).
      egli:ADD(p).
    }

    if nocflist:CONTAINS(p:NAME) {
      set stopWalk to True.
    }

    if stopWalk { return True. }

    local children to p:CHILDREN.
    for child IN children {
      eTree(child,l+1).
    }
    if p:HASPARENT {
      eTree(p:PARENT,l-1).
    }

    return True.
  }

  function setConThru {
    parameter x, i.

    local conF to fuliZ:COPY.
    local thruVF to fuliZ:COPY.
    local thruAF to fuliZ:COPY.

    local pthrustvac IS x:POSSIBLETHRUSTAT(0).
    local pthrustcur IS x:POSSIBLETHRUST.

    if atmo:ISTYPE("Scalar") {
      if atmo < 0 {
        return 0.
      }
      if atmo > 100 {
        return 0.
      }
      set pthrustcur to x:POSSIBLETHRUSTAT(atmo).
    } else {
      set atmo to "current pressure".
    }

    local tlimit IS x:THRUSTLIMIT/100.
    for fkey IN x:CONSUMEDRESOURCES:KEYS {
      local cRes to x:CONSUMEDRESOURCES[fkey].
      local fname to cRes:NAME.
      local fti to fuli:FIND(fname).

      if fti >= 0 {
        set conF[fti] to cRes:MAXMASSFLOW*tlimit.
        set thruVF[fti] to pthrustvac.
        set thruAF[fti] to pthrustcur.
      } else if fname = "ElectricCharge" {
        // ignored
      } else {
        print "Unknown fuel: " + fname.
        print 1/0.
      }
    }

    if conF[LFidx]*conF[OXidx] > 0 {
      set conF[0] to 0.
      set thruVF[0] to 0.
      set thruAF[0] to 0.
    }

    from {local s IS 0.} until s > STAGE:NUMBER step {set s to s+1.} do {
      if s <= x:STAGE AND s > x:DECOUPLEDIN {
        from {local x IS 0.} until x >= fuli:LENGTH step {set x to x+1.} do {
          set con[i][s][x] to con[i][s][x] + conF[x].
          set thruV[i][s][x] to thruV[i][s][x] + thruVF[x].
          set thruA[i][s][x] to thruA[i][s][x] + thruAF[x].

          set sticon[s] to sticon[s] + conF[x]*fuCorr[x].
          set stithruV[s] to stithruV[s] + thruVF[x].
          set stithruA[s] to stithruA[s] + thruAF[x].
        }
      }
    }
  }
}