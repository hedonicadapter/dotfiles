#!/usr/bin/env bash
# PostToolUse guard: flag edits touching settings tied to the 2025 Ryzen 9800X3D
# failures (SoC voltage creeping above ~1.25 V and PBO current limits on AM5 boards,
# mostly ASRock; EXPO suspected). Only text the edit added is scanned, so existing
# mentions elsewhere in a file don't trigger it.
set -euo pipefail
command -v jq >/dev/null || exit 0

input=$(cat)
file=$(jq -r '.tool_input.file_path // .tool_response.filePath // ""' <<<"$input")
added=$(jq -r '[.tool_input.new_string?, .tool_input.content?, (.tool_input.edits[]?.new_string)]
  | map(select(. != null)) | join("\n")' <<<"$input")
[[ -z "$added" ]] && exit 0

# Failure mechanisms: voltage, current limits, memory overclock, SMU/MSR writers
risk='ryzen[_-]?smu|zenstates|ryzenadj|ryzen[_-]?master|amdctl|wrmsr|msr-tools|/dev/cpu/[^[:space:]]*/msr|precision[ _-]?boost[ _-]?overdrive|\bPBO\b|curve[ _-]?optimi[sz]er|set-co(all|per)|\b(PPT|TDC|EDC)\b|stapm|(fast|slow)-limit|tctl-temp|vsoc|vddcr|soc[ _-]?voltage|uncore[ _-]?voltage|vcore|under-?volt|over-?volt|voltage[ _-]?offset|load[ _-]?line|\bEXPO\b|\bDOCP\b|\b[FU]CLK\b'
# Power/boost policy: not a failure cause by itself, but changes the CPU's load envelope
note='cpuFreqGovernor|scaling_governor|cpupower|amd[_-]pstate|energy_performance_preference|cpufreq/boost|auto-cpufreq|power-profiles-daemon|max_cstate|idle=poll|fancontrol'

hits() { grep -oiE "$1" <<<"$added" | sort -fu | paste -sd, - || true; }
risk_hits=$(hits "$risk")
note_hits=$(hits "$note")

if [[ -n "$risk_hits" ]]; then
  jq -n --arg file "$file" --arg hits "$risk_hits" '{
    decision: "block",
    reason: "x3d-guard: this edit to \($file) touches settings tied to the 2025 Ryzen 7 9800X3D failures (\($hits)). Reported deaths were linked to SoC voltage above ~1.25 V and PBO current limits on AM5 boards (mostly ASRock), with EXPO suspected. Before keeping it, tell the user exactly what it changes about CPU voltage, current or limits, prefer stock behaviour (PBO off, SoC voltage auto or <= 1.20 V, no SMU/MSR writes), and get their explicit go-ahead; otherwise revert it.",
    systemMessage: "x3d-guard: edit to \($file) touches 9800X3D-risk settings (\($hits))"
  }'
elif [[ -n "$note_hits" ]]; then
  jq -n --arg file "$file" --arg hits "$note_hits" '{
    systemMessage: "x3d-guard: edit to \($file) changes CPU power policy (\($hits))",
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: "x3d-guard: this edit to \($file) changes CPU power/boost policy (\($hits)). Not a known 9800X3D failure cause on its own, but mention it to the user and keep the desktop at stock voltage and current behaviour."
    }
  }'
fi
