## Summary

Add one or more package aliases to `vamposer.aliases.json`.

## Alias Entries

List each alias exactly as added:

- `alias-key`: `target-repository`

Examples:

- `ValaFoundation/testcases`: `github.com/ValaFoundation/testcases`
- `MyOrg/my-lib`: `github.com/MyOrg/my-lib`

## Validation

- [ ] Alias key is stable and intended for public use
- [ ] Alias target points to a reachable repository
- [ ] Alias target is in supported format (`owner/repo`, `github.com/owner/repo`, or full URL)
- [ ] I verified there is no duplicate/conflicting alias in `vamposer.aliases.json`

## Optional Context

Add links to docs/repository or short rationale for why this alias should be global.
