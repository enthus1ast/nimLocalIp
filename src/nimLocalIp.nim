import osproc, strutils

when defined(windows):
  const
    cmdWmic = "wmic nicconfig get IPAddress"
    cmdIpconfig = "ipconfig"

  proc wmic*(): seq[string] =
    ## parses the output of `wmic nicconfig get IPAddress`
    ## for a crossplatform version use: `getLocalIps`
    let (outp, code) = execCmdEx(cmdWmic)
    if code != 0: return
    for lineRaw in outp.splitLines():
      var line = lineRaw.strip()
      if line.isEmptyOrWhitespace: continue
      if line.startswith("{"):
        line = line.multiReplace(
          ("{", ""),
          ("}", ""),
          ("\"", ""),
        )
        let parts = line.split(",")
        for part in parts:
          if part.isEmptyOrWhitespace(): continue
          if part.contains(":"): continue # skip ipv6
          result.add part.strip()

  proc ipconfig*(): seq[string] =
    ## parses the output of `ipconfig`
    ## for a crossplatform version use: `getLocalIps`
    let (outp, code) = execCmdEx(cmdIpconfig)
    if code != 0: return
    for line in outp.splitLines():
      if line.isEmptyOrWhitespace: continue
      if line.contains("IPv4"):
        var pos = line.find(":")
        if pos == -1: continue
        pos.inc # skip ":"
        let ip = line[pos..^1].strip()
        result.add ip

when not defined(windows):
  const
    cmdIfconfig = "ifconfig"
    cmdIpa= "ip a"

  proc ifconfig*(): seq[string] =
    ## parses the output of `ifconfig`
    ## for a crossplatform version use: `getLocalIps`
    let (outp, code) = execCmdEx(cmdIfconfig)
    if code != 0: return
    for lineRaw in outp.splitLines():
      let line = lineRaw.strip()
      const inet = "inet "
      if line.startswith(inet):
        var endpos = line.find(" ", start = inet.len)
        endpos.dec # go back to real end
        if endpos == -1: continue
        result.add(line[inet.len .. endpos])

  proc ipa*(): seq[string] =
    ## parses the output of `ip a`
    ## for a crossplatform version use: `getLocalIps`
    let (outp, code) = execCmdEx(cmdIpa)
    if code != 0: return
    for lineRaw in outp.splitLines():
      let line = lineRaw.strip()
      const inet = "inet "
      if line.startswith(inet):
        var endpos = line.find("/", start = inet.len)
        endpos.dec # go back to real end
        if endpos == -1: continue
        result.add(line[inet.len .. endpos])

proc getLocalIps*: seq[string] =
  ## returns the local ip (v4) addresses of your adapters
  ## it parses: `ipconfig` and `wmic` (windows), `ifconfig` and `ip a` on (*ix)
  when defined(windows):
    result = ipconfig()
    if result.len == 0:
      result = wmic()
  else:
    result = ipa()
    if result.len == 0:
      result = ifconfig()

when isMainModule:
  echo getLocalIps()
