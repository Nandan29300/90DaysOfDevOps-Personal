# Day 38 – YAML Basics

## Task Summary

The goal of Day 38 was to understand YAML syntax and rules before starting CI/CD pipelines.

## YAML Files

The following YAML files were created separately:

- `person.yaml` — key-value pairs, lists, and an inline list.
- `server.yaml` — nested objects, credentials, and a multi-line string using `|`.
- `server-fold.yaml` — the same server configuration with a folded multi-line string using `>`.

## Task 1 – Key-Value Pairs

`person.yaml` contains:

- `name`
- `role`
- `experience_years`
- `learning`

The file was checked with `cat person.yaml` to verify that the structure is clean and contains spaces instead of tabs.

[1-2-person.yaml](YAML/1-2-person.yaml)

## Task 2 – Lists

YAML supports lists in two common ways:

### Block style

```yaml
tools:
  - Docker
  - Kubernetes
  - Git
```

### Inline / flow style

```yaml
hobbies: [coding, reading, cricket]
```

The `tools` field uses block style, while `hobbies` uses inline style.

## Task 3 – Nested Objects

`server.yaml` contains nested `server` and `database` objects. The `credentials` object is nested further inside `database`.

YAML indentation defines the hierarchy. Tabs must not be used for indentation. A tab can cause a YAML parser or linter to report an indentation error.

## Task 4 – Multi-line Strings

Two YAML block styles were practiced:

### `|` Literal / block style

The `|` style preserves line breaks.

It is useful for:

- Shell scripts
- Configuration snippets
- Certificates
- Text where exact line breaks matter

### `>` Fold style

The `>` style folds consecutive lines into a single logical line when the YAML is parsed.

It is useful for:

- Long paragraphs
- Human-readable text
- Values that are written across multiple YAML lines but should behave like one line

## Task 5 – Validation

Both valid YAML files should be validated with `yamllint` or another YAML validator.

Example:

```bash
yamllint person.yaml
yamllint server.yaml
yamllint server-fold.yaml
```

An intentionally broken indentation example is included separately as `broken-indentation.yaml`. It should fail YAML validation because `ip` is indented differently from the other keys under `server`.

After correcting the indentation, the YAML becomes valid again.

## Task 6 – Spot the Difference

The first block is correctly indented:

```yaml
name: devops
tools:
  - docker
  - kubernetes
```

The second block is broken:

```yaml
name: devops
tools:
- docker
  - kubernetes
```

The problem is inconsistent indentation in the list. `- docker` is not indented under `tools`, while `- kubernetes` is indented. Both list items should have the same indentation level.

## What I Learned

1. YAML uses indentation to represent structure, so consistent spaces are essential and tabs should never be used for indentation.
2. YAML supports both block-style lists and inline lists, and nested objects are created through indentation.
3. Multi-line strings can use `|` to preserve line breaks or `>` to fold lines, depending on how the value should be interpreted.

## Validation Commands

```bash
cat person.yaml
cat server.yaml

yamllint person.yaml
yamllint server.yaml
yamllint server-fold.yaml
```
