# GitHub Linguist support for G

This directory contains the metadata needed to prepare an upstream submission to `github-linguist/linguist`.

The `.g` extension already exists in Linguist for other languages, so G needs an official language entry plus disambiguation/heuristics before GitHub can globally display `G` as the language name.

Included:

- `G-language.yml` — proposed language metadata
- `grammars/g.tmLanguage.json` — TextMate syntax grammar
- `samples/hello.g` — sample G source

The `language_id` in the draft is only a placeholder and must be replaced with a unique ID accepted by Linguist before submission.
