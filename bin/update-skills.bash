#!/usr/bin/env bash

# Workaround for vercel-labs/skills #1199 & #423 `update` drops --copy and -a.

set -euox pipefail

pushd "$(dirname "${0}")/../dotfiles/claude"

# One `add` per source, with only the skills already listed in the lock file
jq -r '.skills | to_entries | group_by(.value.source)[] | [.[0].value.source] + map(.key) | @tsv' skills-lock.json |
while IFS=$'\t' read -r source skills; do
    args=()
    for s in ${skills}; do
        args+=(--skill "$s");
    done
    pnpx skills@latest add "${source}" --copy --agent claude-code --yes "${args[@]}" < /dev/null
done

popd
