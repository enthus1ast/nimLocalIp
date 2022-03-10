import osproc, strutils

const
  cmdIpconfig = "ipconfig"
  cmdIfconfig = "ifconfig"
  cmdIpa= "ip a"

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
  ## returns the local ip addresses of your adapter
  ## it parses: `ipconfig` (windows), `ifconfig` and `ip a` on (*ix)
  when defined(windows):
    return ipconfig()
  else:
    result = ifconfig()
    if result.len == 0:
      result = ipa()

when isMainModule:
  echo getLocalIps()
