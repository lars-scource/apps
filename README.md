# Apps site (personlig)

Statisk side til App Store:

- **Support URL:** `https://<github-user>.github.io/apps/`
- **Privacy Policy URL:** `https://<github-user>.github.io/apps/privacy.html`

## Indhold

| Fil | Formål |
|-----|--------|
| `index.html` | Support / oversigt |
| `privacy.html` | Dansk privatlivspolitik for Indkvartering |

Dataansvarlig: **Lars Hansen** (privatperson), `lhansen0@me.com`.

## Deploy (GitHub Pages)

```bash
cd ~/apps-site
../indkvartering-app/tools/gh auth login   # én gang
./deploy.sh
```

Eller manuelt: opret offentligt repo `apps`, push indholdet, aktiver Pages (branch `main` / root).
