{
  local dv is lex("burn", burn_mean@).
  // burn(dv, pressure = 0, stageTime = 2), returns [burnMean, burnTime]

  // yuck, but should only do it once.
  global DV_rawDict is lex().
  global DV_deltaVDict is lex().
  global DV_parsed is false.

  function parseDeltaV {
    if DV_parsed return.
    parameter pressure is 0.

    local stagePartDict is lex().
    local stageEngineDict is lex().
    local highStage to 0.
    local shipParts to list().
    list parts in shipParts.

    for part in shipParts {
      if part:typename = "ENGINE" and part:name <> "sepMotor1" {
        // TODO Ignore or manually work with solid rocket boosters
        local sNum to part:stage.
        if stageEngineDict:haskey(sNUM) = false {
          set stageEngineDict[sNum] to list().
          set highStage to max(highStage, sNum).
        }
        stageEngineDict[sNum]:add(part).
      } else {
        local sNum to part:stage + 1.
        if stagePartDict:haskey(sNum) = false {
          set stagePartDict[sNum] to list().
          set DV_rawDict[sNum] to list(0,0,0,0,0,list()).
          set highStage to max(highStage, sNum).
        }
        stagePartDict[sNum]:add(part).
        set DV_rawDict[sNum][0] to DV_rawDict[sNum][0] + part:MASS.
        set DV_rawDict[sNum][1] to DV_rawDict[sNum][1] + part:DRYMASS.
      }
    }

    lock throttle to 0.
    for stageNum in stageEngineDict:KEYS {
      for eng in stageEngineDict[stageNum] {
        local maxStage to eng:stage.
        local minStage to eng:parent:stage + 1.

        set DV_rawDict[minStage][0] to DV_rawDict[minStage][0] + eng:MASS.
        set DV_rawDict[minStage][1] to DV_rawDict[minStage][1] + eng:DRYMASS.

        for relevStage in Range(minStage, maxStage + 1) {
          If DV_rawDict:haskey(relevStage) = false {
            set stagePartDict[relevStage] to list().
            set DV_rawDict[relevStage] to list(0,0,0,0,0,list()).
            set highStage to max(highStage, relevStage).
          }
          set DV_rawDict[relevStage][2] to DV_rawDict[relevStage][2] + eng:possiblethrustat(pressure)/eng:ispat(pressure).
          set DV_rawDict[relevStage][3] to DV_rawDict[relevStage][3] + eng:possiblethrustat(pressure).
          set DV_rawDict[relevStage][4] to DV_rawDict[relevStage][4] + eng:possiblethrustat(pressure)/(eng:ispat(pressure) * constant:g0).
          DV_rawDict[relevStage][5]:add(eng).
        }
      }
    }
    for stageNum in DV_rawDict:KEYS {
      if DV_rawDict[stageNum][2] <> 0 {
        set DV_rawDict[stageNum][2] to DV_rawDict[stageNum][3]/DV_rawDict[stageNum][2].
      }
    }

    local accMass to 0.
    for stageNum in Range(0, highStage + 1) {
      if DV_rawDict:haskey(stageNum) = false {
        DV_rawDict:add(stageNum, list(0,0,0,0,0,list())).
      }
      set DV_deltaVDict[stageNum] to list(0, 0, 0, 0).
      set DV_deltaVDict[stageNum][0] to constant:g0 * DV_rawDict[stageNum][2] * ln((accMass + DV_rawDict[stageNum][0])/(accMass + DV_rawDict[stageNum][1])).
      set DV_deltaVDict[stageNum][1] to DV_rawDict[stageNum][3]/(accMass + DV_rawDict[stageNum][0])/constant:g0.
      set DV_deltaVDict[stageNum][2] to DV_rawDict[stageNum][3]/(accMass + DV_rawDict[stageNum][1])/constant:g0.
      set accMass to accMass + DV_rawDict[stageNum][0].
      set DV_deltaVDict[stageNum][3] to accMass.
    }
    set DV_parsed to true.
  }

  function burn_mean {
    parameter dv, pressure to 0, stageTime to 2.
    local wholeDV to 0.
    local burnTime to 0.
    local burnMean to 0.
    local finalStage to stage:number.
    local deltV to 0.

    // problem if you parsed at different pressure, but not using it, so meh.
    if not DV_parsed parseDeltaV(pressure).

    until (wholeDV >= dv) {
      if DV_deltaVDict:haskey(finalStage) { set deltV to DV_deltaVDict[finalStage][0]. } else { set deltV to 0. }
      if deltV >= dv - wholeDV {
        set deltV to dv - wholeDV.
      }
      if deltV > 0 {
        set wholeDV to wholeDV + deltV.
        local F to DV_rawDict[finalStage][3].
        local m_d to DV_rawDict[finalStage][4].
        local m_0 to DV_deltaVDict[finalStage][3].
        local t_1 to - (CONSTANT:E^(ln(m_0)-(deltV*m_d)/F)-m_0)/m_d.
        local t_m to (m_0*ln((m_d*t_1-m_0)/-m_0)+m_d*t_1)/(m_d*ln((m_0-m_d*t_1)/m_0)).
        set burnMean to burnMean + (burnTime + t_m)*deltV.
        set burnTime to burnTime + stageTime + t_1.
      }

      set finalStage to finalStage - 1.
      if finalStage < 0 break.
    }
    if wholeDV > 0 {
      set burnMean to burnMean/wholeDV.
      return list(burnMean, burnTime).
    } else { return list(0,0). }
  }

  export(dv).
}