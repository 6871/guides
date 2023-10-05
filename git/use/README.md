# Using Git

* [Branching](#branching)
* [Merging](#merging)
* [Rebasing](#rebasing)
* [Stashing](#stashing)
* [Tagging](#tagging)
* [Undoing Changes](#undoing-changes)
* [Viewing Changes](#viewing-changes)
* [Viewing History](#viewing-history)

## Branching

```bash
# Create local branch
git checkout -b "${BRANCH_NAME:?}"
```

```bash
# Delete local branch
git branch --delete "${BRANCH_NAME:?}"
```

```bash
# Delete remote branch
git push origin --delete "${BRANCH_NAME:?}"
```

```bash
# Remove local tracking branches not on the origin
git remote prune origin --dry-run
git remote prune origin
```

## Merging

```bash
git merge "${FROM_BRANCH_NAME:?}"
git merge --squash "${FROM_BRANCH_NAME:?}"
git merge --squash "${FROM_BRANCH_NAME:?}" -m "${MESSAGE:?}"
```

## Rebasing

```bash
git rebase "${FROM_BRANCH_NAME:?}"
```

## Stashing

```bash
git stash push
git stash list
git stash pop
```

## Tagging

```bash
# Create an annotated and signed tag (COMMIT_HASH is optional)
git tag --annotate --sign \
  --message "${TAG_MESSAGE:?}" \
  "${TAG_NAME:?}" \
  "${COMMIT_HASH:?}"

# Create a lightweight tag (COMMIT_HASH is optional)
git tag "${TAG_NAME:?}" "${COMMIT_HASH:?}"

# Push tag to server
git push origin "${TAG_NAME:?}"
```

```bash
# Delete a remote tag
git push origin --delete "${TAG_NAME:?}"
```

```bash
# Fetch remote tags
git fetch --tags
```

```bash
# Listing tags
git tag
git tag --list 'foo-*'
```

```bash
# Delete a local tag
git tag --delete "${TAG_NAME:?}"

# Delete all local tags
git tag --list | xargs git tag --delete
```

```bash
# View commit hash that a tag points to
git show --no-patch "${TAG_NAME:?}"

# View tag's own commit hash
git rev-parse "${TAG_NAME:?}"
```

## Undoing Changes

```bash
# Undo last local commit
git reset --soft HEAD~1
```

```bash
# Undo add
git reset "${ADDED_FILENAME:?}"
```

## Viewing Changes

```bash
# Last change
git show
git show --name-only
git diff @~ @
git diff @~ @ --name-only
```

```bash
# Compare current working directory to last commit
git diff
```

```bash
# Compare staged files (git add) with last commit
git diff --staged
```

```bash
# Compare commits, branches and tags
git diff "${THING_1:?}" "${THING_2:?}"
git diff "${THING_1:?}" "${THING_2:?}" --name-only
```

## Viewing History

```bash
# View full log
git log

# View one commit per line
git log --oneline

# View last 3 items
git log -3

# Show commit signature
git log -1 --show-signature
```

```bash
# View deleted items
git log --diff-filter=D --summary
```

```bash
# View only commits with tags
git log -5 --tags
git log -5 --tags --no-walk --oneline
```
