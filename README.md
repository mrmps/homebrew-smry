# smry CLI

`smry` is the official command-line client for the credential-free
[smry Public Reader](https://r.smry.ai). It reads an exact public article, PDF,
or supported YouTube URL as clean text or structured JSON with stable paragraph
anchors.

## Install

```sh
brew install mrmps/smry/smry
```

## Use

```sh
smry https://example.com/article
smry --json https://example.com/report.pdf
smry --query "key findings" https://example.com/article
smry --lines 90-95 https://example.com/article
```

Run `smry --help` for the complete option list.

## Agent skill

Install the official skills for source-grounded reading workflows:

```sh
bunx skills add https://github.com/mrmps/homebrew-smry --skill smry compare-sources verify-citations
```

The skills cover direct reading, multi-source comparison, and claim or citation
verification. They choose between the public MCP, HTTP API, and CLI, preserve
stable paragraph citations, and treat retrieved content as untrusted data.

The CLI sends only the exact source URL and the options you provide to
`https://r.smry.ai/api/v1/read`. Do not send private URLs, cookies,
authorization headers, subscriber credentials, or personal documents.

## Public MCP server

Agents can call the same credential-free reader through the remote
Streamable HTTP MCP server at `https://r.smry.ai/mcp`. Its official registry
metadata is versioned in [`server.json`](server.json); the endpoint provides a
source-reading tool plus documentation resources and requires no account or
secret.

## Verify

```sh
bash -n bin/smry
./tests/smry-cli.test.sh
```

## License

MIT
