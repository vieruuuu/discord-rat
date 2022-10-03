import osproc
import os
import strutils
import times

proc getUptime*(): TimeInterval =
    let currentUserName = getEnv("USERNAME").toLower()
    let outputLines = execProcess("quser").toLower().split("\n>")

    for line in outputLines:
        if not line.contains(currentUserName):
            continue

        let noWhitespace = line.splitWhitespace()

        let AMorPM = noWhitespace[noWhitespace.len - 1]
        let time = noWhitespace[noWhitespace.len - 2]
        let date = noWhitespace[noWhitespace.len - 3]

        let dt = parse(date & ' ' & time & AMorPM, "M/d/yyyy h:mmtt")

        return between(dt, now())
