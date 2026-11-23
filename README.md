# Ticketflow — deployments

Desired state of the Ticketflow environments, delivered by Argo CD (GitOps).
Code and Helm charts live in [JustPrzemek/ticketflow](https://github.com/JustPrzemek/ticketflow);
this repository only says **which version runs where and with which settings**.
Decision: [ADR-0019](https://github.com/JustPrzemek/ticketflow/blob/main/docs/adr/0019-gitops-repository-and-secrets.md).

```text
environments/
├── qa/<service>/values.yaml      # follows main automatically (CI commits the new SHA)
└── prod/<service>/values.yaml    # changed only by a promotion pull request
platform/                         # cluster add-ons (Argo CD apps, Sealed Secrets controller)
```

## Rules

- **Version = full commit SHA** of `JustPrzemek/ticketflow`: the image
  `ghcr.io/justprzemek/ticketflow-<service>:<sha>` and the chart from the same commit. Never `latest`.
- **Values files hold only what differs** from the chart defaults.
- **No plain secrets.** Secrets are committed only as `SealedSecret` (`sealed-secrets.yaml` next to
  the values), sealed separately for each environment with `kubeseal`.
- A deployment or a rollback is a commit here; the history of this repository is the deployment log.

## License

[PolyForm Noncommercial 1.0.0](LICENSE.md)
