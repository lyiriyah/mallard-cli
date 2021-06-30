import strformat
import os
from unicode import toLower
import json
import strutils
import cli

# An unbelievable amount of shit gets done here

# Update server, I *guess* this counts as a config option if you change your GooseUpdate server
const updatesUrl = "https://updates.goosemod.com"

# Discord per-platform module folder parent
var baseDirectory: string
case hostOS:
    of "windows":
        baseDirectory = os.getEnv("appdata")
    of "macosx":
        baseDirectory = joinPath(os.getHomeDir(), "~/Library/Application Support")
    of "linux":
        baseDirectory = joinPath(os.getHomeDir(), ".config")
    else:
        echo(fmt"{hostOS} is not a supported platform.", "Unsupported platform")
        quit(0)

# A list of every single Discord channel
# Note that Stable is only here for labels in the UI, the string isn't used for generating anything
const discordChannels = ["Stable", "Canary", "PTB", "Development"]

# Function for formatting Discord paths
proc getChannelPath(channel: string): string =
    # Path to passed Discord channel's modules directory
    var channelPath = os.joinPath(baseDirectory, "discord")

    # Discord stable doesn't have a suffix so it's ignored
    if channel != "Stable":
        channelPath = channelPath & channel.toLower()

    return channelPath

# Function for getting all installed Discord channels
proc getAllInstalledInstances(): seq[string] =
    var installedChannels: seq[string]
    for channel in discordChannels:
        if fileExists(os.joinPath(getChannelPath(channel), "settings.json")):
            installedChannels.add(channel)

    return installedChannels

let selectedChannel = promptList(dontForcePrompt, "Channel to install onto?", getAllInstalledInstances())
let selectedChannelPath = getChannelPath(selectedChannel)
let selectedChannelConfig = selectedChannelPath & "/settings.json"

let installGoosemod = prompt(forcePromptYes, "Install Goosemod?")

# echo selectedChannelConfig
# echo installGoosemod

var modList: seq[string]

if installGoosemod:
  modList.add("goosemod")

let modString = modList.join("+")

var parsedSettings = parseFile(selectedChannelConfig)

parsedSettings.add("NEW_UPDATE_ENDPOINT", %fmt"{updatesUrl}/{modstring}/")
parsedSettings.add("UPDATE_ENDPOINT", %fmt"{updatesUrl}/{modstring}")

writeFile(selectedChannelConfig, parsedSettings.pretty())

display("Success:", fmt"Installed Goosemod onto Discord {selectedChannel}. Please restart Discord.", Success, HighPriority)
